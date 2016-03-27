class TpaCsp < ActiveRecord::Base
	belongs_to :file_upload
	default_scope -> { order(created_at: :desc) }

end
