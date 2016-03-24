class FileUploadsController < ApplicationController
  before_action :set_file_upload, only: [:show, :edit, :update]
  before_filter :same_user, only:[:index,:new,:create,:edit,:update,:destroy]

  # GET /file_uploads
  # GET /file_uploads.json
  
  def send_hash
      @user = User.find_by_id(params[:user_id])
      @id1 = params[:user_id]
      @file_uploads = FileUpload.find_by_id(params[:file_upload_id])
      @md5 = Digest::MD5.file(@file_uploads.attachment.path).hexdigest 
      @message = RequestMessage.create(:status_code=>502, :file_hash=>@md5, :file_upload_id=>@file_uploads[:id], :user_id=>@id1)
      flash[:success] = "Sent Hash to TPA"
      redirect_to user_file_uploads_path
      #end
  end

  def audit
      @user = User.find(params[:user_id])
      @id1 = params[:user_id]
      @file_uploads = FileUpload.find_by_id(params[:file_upload_id])
      @md5 = Digest::MD5.file(@file_uploads.attachment.path).hexdigest 
      @message = RequestMessage.create(:status_code=>503, :file_upload_id=>@file_uploads[:id], :user_id=>@id1)
      flash[:success] = "Audit Request Sent"
      redirect_to user_file_uploads_path
  end


  def index
    @user=User.find(params[:user_id])
    @file_uploads = @user.file_uploads.paginate(page: params[:page], :per_page => 10)
    
  end

  # GET /file_uploads/1
  # GET /file_uploads/1.json
  def show
    @user=User.find(params[:user_id])
    @file = FileUpload.find(params[:id])
    @keywords = Keyword.where(:file_upload_id => @file.id)
  end

  # GET /file_uploads/new
  def new
    @file_upload = @user.file_uploads.new
  end

  # GET /file_uploads/1/edit
  def edit
   # @user=User.find(params[:user_id])
  end

  # POST /file_uploads
  # POST /file_uploads.json
  def create
    @user=User.find(params[:user_id])
    @file_upload = @user.file_uploads.new(file_upload_params)
    
    respond_to do |format|
      if @file_upload.save
        format.html { redirect_to user_file_upload_path(@user,@file_upload), notice: 'File was successfully uploaded.' }
        format.json { render :show, status: :created, location: @file_upload }
        @md5 = Digest::MD5.file(@file_upload.attachment.path).hexdigest 
        @file_upload[:hash_val]=@md5
        @file_upload.save
        @keywords = Keyword.new(:key => params[:keywords], :file_upload_id =>@file_upload.id)
        @keywords.save
      else
        format.html { render :new }
        format.json { render json: @file_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /file_uploads/1
  # PATCH/PUT /file_uploads/1.json
  def update
    respond_to do |format|

      if @file_upload.update(file_upload_params)
        format.html { redirect_to user_file_upload_path, notice: 'File was successfully updated.' }
        format.json { render :show, status: :ok, location: @file_upload }
        @md5 = Digest::MD5.file(@file_upload.attachment.path).hexdigest 
        @file_upload[:hash_val]=@md5
        @file_upload.save
      else
        format.html { render :edit }
        format.json { render json: @file_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /file_uploads/1
  # DELETE /file_uploads/1.json
  def destroy
    @user = User.find(current_user)
    @file_upload=@user.file_uploads.find(params[:id])
    @file_upload.destroy
    respond_to do |format|
      format.html { redirect_to user_file_uploads_path, notice: 'File was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_file_upload
      @file_upload = FileUpload.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def file_upload_params
      params.require(:file_upload).permit(:fname, :owner, :ftype, :attachment)
    end

    def send_hash_params
      params.require(:request_message).permit(:user_id, :file_upload_id)
    end



end
