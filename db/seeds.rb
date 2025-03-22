Rails.logger.debug '🌱 Seeding admin user...'

AdminUser.create!(
  email: 'admin@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  user_type: :superadmin
)

Rails.logger.debug '✅ Seeding admin user completed!'
