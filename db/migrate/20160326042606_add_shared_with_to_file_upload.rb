class AddSharedWithToFileUpload < ActiveRecord::Migration
  def change
    add_column :file_uploads, :shared_with, :string ,:default => "Private"
  end
end
