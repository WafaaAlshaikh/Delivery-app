// backend/src/services/ratingsService.js

const { Op, Sequelize } = require('sequelize');
const { Rating, User, Order, DriverProfile,UserAddress, sequelize } = require('../models');
const SentimentAnalyzer = require('./sentimentAnalyzer');

class RatingsService {
  
  static async createRating(orderId, customerId, driverId, rating, comment, deliveryTime) {
    try {
      const sentiment = SentimentAnalyzer.analyze(comment || '');
      
      const newRating = await Rating.create({
        order_id: orderId,
        customer_id: customerId,
        driver_id: driverId,
        rating: rating,
        comment: comment || null,
        delivery_time: deliveryTime || 'on_time',
        sentiment: sentiment.sentiment,
        sentiment_score: sentiment.score,
        keywords: sentiment.keywords
      });

      await RatingsService.updateDriverRating(driverId);

      return newRating;
    } catch (error) {
      console.error('❌ Create rating error:', error);
      throw error;
    }
  }

  static async updateDriverRating(driverId) {
    try {
      const result = await Rating.findAll({
        attributes: [
          [Sequelize.fn('AVG', Sequelize.col('rating')), 'avgRating'],
          [Sequelize.fn('COUNT', Sequelize.col('rating_id')), 'total']
        ],
        where: {
          driver_id: driverId
        }
      });

      if (result && result.length > 0) {
        const avgRating = parseFloat(result[0].dataValues.avgRating || 0);
        const total = parseInt(result[0].dataValues.total || 0);

        const { DriverProfile } = require('../models');
        await DriverProfile.update({
          rating: avgRating,
          total_deliveries: total
        }, {
          where: { user_id: driverId }
        });
      }

      return true;
    } catch (error) {
      console.error('❌ Update driver rating error:', error);
      throw error;
    }
  }

  static async getDriverRatings(driverId, options = {}) {
    try {
      const {
        page = 1,
        limit = 20,
        sentiment = null
      } = options;

      const offset = (page - 1) * limit;
      const where = { driver_id: driverId };

      if (sentiment && sentiment !== 'all') {
        where.sentiment = sentiment;
      }

      const { count, rows } = await Rating.findAndCountAll({
        where,
        order: [['created_at', 'DESC']],
        limit: parseInt(limit),
        offset: parseInt(offset),
        include: [
          {
            model: User,
            as: 'Customer',
            attributes: ['user_id', 'full_name', 'profile_image']
          }
        ]
      });

      const ratings = rows.map(r => {
        const ratingData = r.toJSON();
        return {
          id: ratingData.rating_id,
          order_id: ratingData.order_id,
          customer_name: ratingData.Customer ? ratingData.Customer.full_name : 'Unknown',
          customer_image: ratingData.Customer ? ratingData.Customer.profile_image : '',
          rating: parseFloat(ratingData.rating),
          comment: ratingData.comment,
          date: ratingData.created_at,
          delivery_time: ratingData.delivery_time,
          is_anonymous: ratingData.is_anonymous,
          sentiment: ratingData.sentiment
        };
      });

      return {
        ratings: ratings,
        pagination: {
          total: count,
          page: parseInt(page),
          limit: parseInt(limit),
          totalPages: Math.ceil(count / limit)
        }
      };
    } catch (error) {
      console.error('❌ Get driver ratings error:', error);
      throw error;
    }
  }

  static async getRatingsSummary(driverId) {
    try {
      const now = new Date();
      const monthAgo = new Date();
      monthAgo.setMonth(now.getMonth() - 1);

      const ratings = await Rating.findAll({
        where: { driver_id: driverId },
        attributes: [
          'rating',
          'sentiment',
          [Sequelize.fn('COUNT', Sequelize.col('rating_id')), 'count']
        ],
        group: ['rating', 'sentiment']
      });

      let totalRatings = 0;
      let fiveStar = 0, fourStar = 0, threeStar = 0, twoStar = 0, oneStar = 0;
      let positive = 0, negative = 0, neutral = 0;
      const keywordAnalyses = [];

      for (const r of ratings) {
        const count = parseInt(r.dataValues.count);
        const rating = parseFloat(r.dataValues.rating);
        const sentiment = r.dataValues.sentiment;

        totalRatings += count;

        if (rating >= 4.5) fiveStar += count;
        else if (rating >= 3.5) fourStar += count;
        else if (rating >= 2.5) threeStar += count;
        else if (rating >= 1.5) twoStar += count;
        else oneStar += count;

        if (sentiment === 'positive') positive += count;
        else if (sentiment === 'negative') negative += count;
        else if (sentiment === 'neutral') neutral += count;

        const keywords = r.dataValues.keywords;
        if (keywords) {
          keywordAnalyses.push({ keywords });
        }
      }

      const avgResult = await Rating.findOne({
        attributes: [
          [Sequelize.fn('AVG', Sequelize.col('rating')), 'avgRating']
        ],
        where: { driver_id: driverId }
      });
      const averageRating = parseFloat(avgResult?.dataValues?.avgRating || 0);

      const currentMonth = await Rating.count({
        where: {
          driver_id: driverId,
          created_at: { [Op.gte]: monthAgo }
        }
      });

      const previousMonth = await Rating.count({
        where: {
          driver_id: driverId,
          created_at: { [Op.lt]: monthAgo }
        }
      });

      const monthlyChange = previousMonth > 0 
        ? ((currentMonth - previousMonth) / previousMonth) * 100 
        : currentMonth > 0 ? 100 : 0;

      const topKeywords = SentimentAnalyzer.extractTopKeywords(keywordAnalyses);

      const sentimentTrends = SentimentAnalyzer.analyzeTrends(
        ratings.map(r => ({ sentiment: r.dataValues.sentiment }))
      );

      return {
        average_rating: parseFloat(averageRating.toFixed(1)),
        total_ratings: totalRatings,
        five_star_count: fiveStar,
        four_star_count: fourStar,
        three_star_count: threeStar,
        two_star_count: twoStar,
        one_star_count: oneStar,
        positive_percentage: parseFloat(((positive / totalRatings) * 100).toFixed(1)) || 0,
        neutral_percentage: parseFloat(((neutral / totalRatings) * 100).toFixed(1)) || 0,
        negative_percentage: parseFloat(((negative / totalRatings) * 100).toFixed(1)) || 0,
        monthly_change: parseFloat(monthlyChange.toFixed(1)),
        top_keywords: topKeywords
      };
    } catch (error) {
      console.error('❌ Get ratings summary error:', error);
      throw error;
    }
  }

  static async getAIInsights(driverId) {
    try {
      const ratings = await Rating.findAll({
        where: { driver_id: driverId },
        attributes: ['rating', 'comment', 'sentiment', 'keywords']
      });

      if (ratings.length === 0) {
        return {
          strengths: [],
          weaknesses: [],
          suggestions: ['قم بإكمال المزيد من التوصيلات للحصول على تحليل كامل'],
          recommendations: ['اطلب من العملاء تقييم خدمتك'],
          overall_assessment: 'لا توجد بيانات كافية للتحليل',
          improvement_score: 0,
          category_scores: {}
        };
      }

      const ratingsList = ratings.map(r => r.toJSON());
      const avgRating = ratingsList.reduce((sum, r) => sum + parseFloat(r.rating), 0) / ratingsList.length;
      
      const positiveComments = ratingsList.filter(r => r.sentiment === 'positive');
      const negativeComments = ratingsList.filter(r => r.sentiment === 'negative');
      const neutralComments = ratingsList.filter(r => r.sentiment === 'neutral');

      const allKeywords = ratingsList.flatMap(r => r.keywords || []);
      const keywordFrequency = {};
      for (const kw of allKeywords) {
        keywordFrequency[kw] = (keywordFrequency[kw] || 0) + 1;
      }

      const sortedKeywords = Object.entries(keywordFrequency)
        .sort((a, b) => b[1] - a[1])
        .map(([key]) => key);

      const positiveKeywords = ratingsList
        .filter(r => r.sentiment === 'positive')
        .flatMap(r => r.keywords || []);
      
      const positiveFreq = {};
      for (const kw of positiveKeywords) {
        positiveFreq[kw] = (positiveFreq[kw] || 0) + 1;
      }
      const strengths = Object.entries(positiveFreq)
        .sort((a, b) => b[1] - a[1])
        .slice(0, 3)
        .map(([key]) => key);

      const negativeKeywords = ratingsList
        .filter(r => r.sentiment === 'negative')
        .flatMap(r => r.keywords || []);
      
      const negativeFreq = {};
      for (const kw of negativeKeywords) {
        negativeFreq[kw] = (negativeFreq[kw] || 0) + 1;
      }
      const weaknesses = Object.entries(negativeFreq)
        .sort((a, b) => b[1] - a[1])
        .slice(0, 3)
        .map(([key]) => key);

      const improvementScore = Math.min(100, Math.max(0, 
        (avgRating / 5) * 70 + 
        (positiveComments.length / ratingsList.length) * 30
      ));

      const suggestions = [];
      if (avgRating < 4) {
        suggestions.push('📈 ركز على تحسين سرعة التوصيل');
      }
      if (negativeComments.length > positiveComments.length * 0.5) {
        suggestions.push('🤝 تحسين مهارات التواصل مع العملاء');
      }
      if (weaknesses.includes('بطيء') || weaknesses.includes('متأخر')) {
        suggestions.push('⏰ خطط لمسارك بشكل أفضل لتجنب التأخير');
      }
      if (weaknesses.includes('غير محترم') || weaknesses.includes('وقح')) {
        suggestions.push('💬 تدرب على مهارات التواصل الإيجابي');
      }

      if (suggestions.length === 0) {
        suggestions.push('🌟 استمر بالعمل الجيد وحافظ على أدائك الممتاز');
      }

      const recommendations = SentimentAnalyzer.generateRecommendations({
        strengths,
        weaknesses,
        improvementScore
      });

      let overallAssessment;
      if (avgRating >= 4.5) {
        overallAssessment = '🌟 أداء ممتاز! العملاء راضون جداً عن خدمتك. استمر على هذا المستوى!';
      } else if (avgRating >= 3.5) {
        overallAssessment = '👍 أداء جيد. هناك مجال للتحسين في بعض النقاط.';
      } else {
        overallAssessment = '⚠️ أداء يحتاج للتحسين. ركز على نقاط الضعف المحددة.';
      }

      const categoryScores = {
        'سرعة التوصيل': avgRating >= 4 ? 85 : avgRating >= 3 ? 65 : 45,
        'التواصل': positiveComments.length / ratingsList.length * 100,
        'الدقة': avgRating >= 4.5 ? 90 : avgRating >= 3.5 ? 70 : 50,
        'المظهر العام': avgRating >= 4 ? 80 : avgRating >= 3 ? 60 : 40
      };

      return {
        strengths: strengths,
        weaknesses: weaknesses,
        suggestions: suggestions,
        recommendations: recommendations,
        overall_assessment: overallAssessment,
        improvement_score: Math.round(improvementScore),
        category_scores: categoryScores
      };
    } catch (error) {
      console.error('❌ Get AI insights error:', error);
      throw error;
    }
  }

static async getCityAnalytics(driverId) {
  try {
    console.log('📍 Getting city analytics for driver:', driverId);
    
    const ratings = await Rating.findAll({
      where: { driver_id: driverId },
      include: [
        {
          model: Order,
          include: [
            {
              model: UserAddress,
              attributes: ['city', 'street', 'country']
            }
          ]
        }
      ]
    });

    console.log(`📊 Found ${ratings.length} ratings`);

    const cityData = {};
    
    for (const rating of ratings) {
      const order = rating.Order;
      if (!order) continue;

      let city = 'Unknown';
      if (order.UserAddress && order.UserAddress.city) {
        city = order.UserAddress.city;
      }

      if (!cityData[city]) {
        cityData[city] = {
          city: city,
          totalRatings: 0,
          totalScore: 0,
          positiveCount: 0,
          negativeCount: 0,
          neutralCount: 0,
          keywords: [],
        };
      }

      cityData[city].totalRatings++;
      cityData[city].totalScore += parseFloat(rating.rating);

      if (rating.sentiment === 'positive') cityData[city].positiveCount++;
      else if (rating.sentiment === 'negative') cityData[city].negativeCount++;
      else if (rating.sentiment === 'neutral') cityData[city].neutralCount++;

      if (rating.keywords) {
        cityData[city].keywords.push(...rating.keywords);
      }
    }

    const result = {};
    for (const [city, data] of Object.entries(cityData)) {
      const total = data.totalRatings;
      const avgRating = total > 0 ? data.totalScore / total : 0;
      
      const keywordCount = {};
      for (const kw of data.keywords) {
        if (kw && kw.length > 0) {
          keywordCount[kw] = (keywordCount[kw] || 0) + 1;
        }
      }
      const topKeywords = Object.entries(keywordCount)
        .sort((a, b) => b[1] - a[1])
        .slice(0, 5)
        .map(([key]) => key);

      result[city] = {
        city: city,
        average_rating: parseFloat(avgRating.toFixed(1)),
        total_ratings: total,
        positive_count: data.positiveCount,
        negative_count: data.negativeCount,
        neutral_count: data.neutralCount,
        positive_percentage: total > 0 ? parseFloat(((data.positiveCount / total) * 100).toFixed(1)) : 0,
        negative_percentage: total > 0 ? parseFloat(((data.negativeCount / total) * 100).toFixed(1)) : 0,
        neutral_percentage: total > 0 ? parseFloat(((data.neutralCount / total) * 100).toFixed(1)) : 0,
        top_keywords: topKeywords,
        sentiment_breakdown: {
          positive: data.positiveCount,
          negative: data.negativeCount,
          neutral: data.neutralCount,
        }
      };
    }

    return result;
  } catch (error) {
    console.error('❌ Get city analytics error:', error);
    throw error;
  }
}

  static async getDriverRanking(driverId) {
    try {
      const drivers = await DriverProfile.findAll({
        where: { status: 'Active' },
        include: [
          {
            model: User,
            attributes: ['user_id', 'full_name', 'profile_image'],
          }
        ],
        order: [['rating', 'DESC']]
      });

      const currentDriver = await DriverProfile.findOne({
        where: { user_id: driverId },
        include: [
          {
            model: User,
            attributes: ['user_id', 'full_name', 'profile_image'],
          }
        ]
      });

      if (!currentDriver) {
        throw new Error('Driver not found');
      }

      const topDrivers = drivers.slice(0, 10).map((d, index) => ({
        driver_id: d.user_id,
        name: d.User?.full_name || 'Unknown',
        rating: parseFloat(d.rating || 0),
        total_deliveries: d.total_deliveries || 0,
        image: d.User?.profile_image || null,
        rank: index + 1,
      }));

      let currentRank = topDrivers.findIndex(d => d.driver_id === driverId) + 1;
      if (currentRank === 0) {
        const allDrivers = await DriverProfile.findAll({
          where: { status: 'Active' },
          order: [['rating', 'DESC']]
        });
        currentRank = allDrivers.findIndex(d => d.user_id === driverId) + 1;
      }

      const totalDrivers = await DriverProfile.count({ 
        where: { status: 'Active' } 
      });

      return {
        current_rank: currentRank,
        total_drivers: totalDrivers,
        average_rating: parseFloat(currentDriver.rating || 0),
        top_drivers: topDrivers,
      };
    } catch (error) {
      console.error('❌ Get driver ranking error:', error);
      throw error;
    }
  }

  static async getRatingReport(driverId, year, month) {
    try {
      const startDate = new Date(year, month - 1, 1);
      const endDate = new Date(year, month, 1);

      const ratings = await Rating.findAll({
        where: {
          driver_id: driverId,
          created_at: {
            [Op.gte]: startDate,
            [Op.lt]: endDate
          }
        },
        include: [
          { model: User, as: 'Customer', attributes: ['full_name'] }
        ],
        order: [['created_at', 'DESC']]
      });

      const total = ratings.length;
      
      const avgRating = total > 0 
        ? ratings.reduce((sum, r) => sum + parseFloat(r.rating), 0) / total 
        : 0;

      const positive = ratings.filter(r => r.sentiment === 'positive').length;
      const neutral = ratings.filter(r => r.sentiment === 'neutral').length;
      const negative = ratings.filter(r => r.sentiment === 'negative').length;

      const cityData = {};
      for (const rating of ratings) {
        const city = 'Unknown';
        if (!cityData[city]) {
          cityData[city] = {
            average_rating: 0,
            total_ratings: 0,
            positive_percentage: 0,
          };
        }
        cityData[city].total_ratings++;
        cityData[city].average_rating = 
          (cityData[city].average_rating * (cityData[city].total_ratings - 1) + parseFloat(rating.rating)) 
          / cityData[city].total_ratings;
      }

      return {
        summary: {
          total_ratings: total,
          average_rating: parseFloat(avgRating.toFixed(1)),
          positive_percentage: total > 0 ? (positive / total) * 100 : 0,
          neutral_percentage: total > 0 ? (neutral / total) * 100 : 0,
          negative_percentage: total > 0 ? (negative / total) * 100 : 0,
        },
        sentiment_breakdown: {
          positive,
          neutral,
          negative,
        },
        cities: cityData,
        ratings: ratings.map(r => ({
          date: r.created_at,
          customer_name: r.Customer?.full_name || 'Unknown',
          rating: r.rating,
          comment: r.comment,
        })),
      };
    } catch (error) {
      console.error('❌ Get rating report error:', error);
      throw error;
    }
  }
}

module.exports = RatingsService;