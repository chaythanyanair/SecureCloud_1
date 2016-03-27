class AddReferencesToSharedUser < ActiveRecord::Migration
  def change
	add_reference :shared_users, :user, index: true, foreign_key: true
	add_reference :shared_users, :file_upload, index: true, foreign_key: true

  end
end
