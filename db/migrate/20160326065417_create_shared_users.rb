class CreateSharedUsers < ActiveRecord::Migration
  def change
    create_table :shared_users do |t|

      t.timestamps null: false
    end
  end
end
