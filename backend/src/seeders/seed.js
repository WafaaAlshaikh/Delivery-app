// seeders/seed.js
const { 
  Role, 
  OrderStatus, 
  PaymentMethod, 
  PaymentStatus,
  sequelize 
} = require('../src/models');

const seedDatabase = async () => {
  try {
    console.log('🌱 Starting database seeding...');

    // ============ 1. Roles ============
    const roles = [
      { name: 'Admin', description: 'Full system access' },
      { name: 'Merchant', description: 'Business owner' },
      { name: 'Driver', description: 'Delivery driver' },
      { name: 'Customer', description: 'Regular customer' },
      { name: 'Support', description: 'Customer support agent' }
    ];

    for (const role of roles) {
      await Role.findOrCreate({
        where: { name: role.name },
        defaults: role
      });
    }
    console.log('✅ Roles seeded successfully');

    // ============ 2. Order Statuses ============
    const orderStatuses = [
      { name: 'Pending', color: '#FFA500' },
      { name: 'Accepted', color: '#4CAF50' },
      { name: 'Preparing', color: '#2196F3' },
      { name: 'Ready', color: '#8BC34A' },
      { name: 'Driver Assigned', color: '#9C27B0' },
      { name: 'Picked Up', color: '#FF9800' },
      { name: 'On The Way', color: '#00BCD4' },
      { name: 'Delivered', color: '#4CAF50' },
      { name: 'Cancelled', color: '#F44336' }
    ];

    for (const status of orderStatuses) {
      await OrderStatus.findOrCreate({
        where: { name: status.name },
        defaults: status
      });
    }
    console.log('✅ Order statuses seeded successfully');

    // ============ 3. Payment Methods ============
    const paymentMethods = [
      { name: 'Cash' },
      { name: 'Visa' },
      { name: 'MasterCard' },
      { name: 'Wallet' },
      { name: 'Apple Pay' },
      { name: 'Google Pay' }
    ];

    for (const method of paymentMethods) {
      await PaymentMethod.findOrCreate({
        where: { name: method.name },
        defaults: method
      });
    }
    console.log('✅ Payment methods seeded successfully');

    // ============ 4. Payment Statuses ============
    const paymentStatuses = [
      { name: 'Pending' },
      { name: 'Paid' },
      { name: 'Failed' },
      { name: 'Refunded' }
    ];

    for (const status of paymentStatuses) {
      await PaymentStatus.findOrCreate({
        where: { name: status.name },
        defaults: status
      });
    }
    console.log('✅ Payment statuses seeded successfully');

    console.log('🎉 Database seeding completed successfully!');

  } catch (error) {
    console.error('❌ Error seeding database:', error);
    throw error;
  }
};

// Export the function
module.exports = seedDatabase;

// If run directly: node seeders/seed.js
if (require.main === module) {
  (async () => {
    try {
      await sequelize.sync();
      await seedDatabase();
      console.log('✨ Seeding finished, closing connection...');
      process.exit(0);
    } catch (error) {
      console.error('💥 Fatal error during seeding:', error);
      process.exit(1);
    }
  })();
}