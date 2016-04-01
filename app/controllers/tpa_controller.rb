class TpaController < ApplicationController
  def new
  end
  def create    
  end
  def edit
  end
  def update
   # @req = RequestMessage.find_by_id(params[:id])
  end
  def destroy
    if(params[:flag])
      @req = RequestMessage.find_by_id(params[:id])
      if @req.present?
        @req.destroy
      end
    else
      @resp = TpaCsp.find_by_id(params[:id])
      if @resp.present?
        @resp.destroy
      end
    end
    flash[:success] = "Message Deleted"
    @user = User.find_by_id(1)
    @req = RequestMessage.all
    @resp = TpaCsp.all
    render 'show'
  end

  def destroy_multiple
    if(params[:flag])
      RequestMessage.destroy(params[:messages])
    else 
      TpaCsp.destroy(params[:messages])
    end
    flash.now[:success] = "Messages Destroyed Successfully"
    @user = User.find_by_id(1)
    @req = RequestMessage.all
    @resp = TpaCsp.all
    render 'show'
  end
  def challenge
    @reqs = RequestMessage.find_by_id(params[:id])
   # @file=Tpa.create(:file_upload_id=>@reqs.file_upload_id,:file_hash => @reqs.file_hash)
    @message = TpaCsp.create(:status_code=>503, :file_upload_id=>@reqs.file_upload_id)
    flash[:success] = "Challenged CSP"
    redirect_to tpa_path(1)
  end

  def verify
    @req = TpaCsp.find_by_id(params[:id])
    @file_id = @req.file_upload_id
    @file = Tpa.find_by_file_upload_id(@file_id)
    @file_hash = @file.file_hash
    @user_id=getuserid(@file_id)
    if(@file_hash==@req.file_hash)
      @message = RequestMessage.create(:status_code=>504, :file_upload_id=>@req.file_upload_id,:user_id=>@user_id,:file_hash=>"File is verified and found to be correct!")
    else
      @message = RequestMessage.create(:status_code=>504, :file_upload_id=>@req.file_upload_id,:user_id=>@user_id,:file_hash=>"File is verified and found to be faulty!")

    end
    flash[:success] = "Verified and result sent" 
    redirect_to tpa_path(1)
  end

  def update_hash
    @file=Tpa.new
    @req = RequestMessage.find_by_id(params[:id])
    @file=Tpa.create(:file_upload_id=>@req.file_upload_id,:file_hash => @req.file_hash)
    flash[:success] = "Hash Updated"
    redirect_to tpa_path(1)
  end
  def index
    redirect_to tpa_path(1)
    @user = User.find_by_id(1)
    @req = RequestMessage.all
  end
  def show
    @user = User.find_by_id(1)
    @req = RequestMessage.all
    @resp = TpaCsp.all
  end

  private
    def getuserid(file_id)
      @file=FileUpload.find_by_id(file_id)
      @user_id=@file.user_id
      return @user_id
    end

end
