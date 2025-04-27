Rails.logger.debug '🌱 Seeding admin user...'

AdminUser.create!(
  email: 'superadmin@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  user_type: :superadmin
)
AdminUser.create!(
  email: 'admin@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  user_type: :admin
)

Rails.logger.debug '✅ Seeding admin user completed!'
