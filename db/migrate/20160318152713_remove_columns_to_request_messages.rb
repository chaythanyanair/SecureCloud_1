class RemoveColumnsToRequestMessages < ActiveRecord::Migration
  def change
  	remove_column :request_messages, :update
  	remove_column :request_messages, :audit
  end
end
