class FileUpload < ActiveRecord::Base
	has_many :request_messages, :dependent=>:destroy
	has_many :tpa_csps, :dependent=>:destroy
	has_many :tpas, :dependent => :destroy
   has_many :keywords, :dependent => :destroy
   has_many :shared_users, :dependent => :destroy
   belongs_to :user
   default_scope -> { order(created_at: :desc) }


   	mount_uploader :attachment, AttachmentUploader # Tells rails to use this uploader for this model.
   	validates :owner, presence: true # Make sure the owner's name is present.
   	validates :fname, presence: true 
   	validates :ftype, presence: true 
   	#validates :keywords, presence: true 
   	validates :user_id, presence: true
end
