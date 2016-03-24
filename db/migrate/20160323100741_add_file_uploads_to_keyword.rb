class AddFileUploadsToKeyword < ActiveRecord::Migration
  def change
  	add_reference :keywords, :file_upload, index: true, foreign_key: true
  end
end
