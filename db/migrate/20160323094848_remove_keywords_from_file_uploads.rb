class RemoveKeywordsFromFileUploads < ActiveRecord::Migration
  def change
  	remove_column :file_uploads, :keywords
  end
end
