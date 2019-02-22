# frozen_string_literal: true

class CreateUser < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :name
      t.string :email
      t.string :token
      t.string :refresh_token
      t.datetime :expires_at
      t.timestamps
    end
  end
end
