class CreateUserLogins < ActiveRecord::Migration
  def change
    create_table :user_logins do |t|
      t.string :email
      t.string :encrypted_password
      t.string :salt
      t.string :confirm_token
      t.boolean :email_confirmed

      t.timestamps null: false
    end
  end
end
