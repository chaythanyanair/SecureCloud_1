class FileUploadsController < ApplicationController
  before_action :set_file_upload, only: [:show, :edit, :update]
  before_filter :same_user, only:[:index,:new,:create,:edit,:update,:destroy]

  rescue_from OpenSSL::Cipher::CipherError, with: :encryption_error

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
    #flash[:success] = AES.encrypt(@file, @key)    
    
    respond_to do |format|
      if @file_upload.save
        
        @file_path = @file_upload.attachment.path
        @file = File.open(@file_path,"rb")
        @file_contents = @file.read
        @file.close

        @key = ENV['encrypt_hash']
        @enc = AES.encrypt(@file_contents, @key)

        @file = File.open(@file_path,"wb")
        @file.write(@enc)
        @file.close

        @file_upload[:fname] = AES.encrypt(params[:file_upload][:fname], @key)

        @md5 = Digest::MD5.file(@file_upload.attachment.path).hexdigest
        @file_upload[:hash_val]=@md5
        
        @keyword = params[:keywords].split(',')
        @keyword.each do |keyword|
          if keyword.length < 3
            s = gram_fuzzy_set(keyword,0)
          elsif keyword.length < 6
            s = gram_fuzzy_set(keyword,1)
          else
            s = gram_fuzzy_set(keyword,2)
          end
          for i in s
            @keyword_enc = Digest::MD5.hexdigest(i)
            @keywords = Keyword.new(:key => @keyword_enc, :file_upload_id =>@file_upload.id)
            @keywords.save
          end
        end
        #inserting shared users
        if(@file_upload.shared_with=="Selected Users")
            @users = params[:shared_users].split(',')
            @users.each do |users|
              @who = User.find_by_email(users)
              @shared = SharedUser.new(:user_id => @who.id , :file_upload_id => @file_upload.id)
              @msg = RequestMessage.create(:status_code=>505, :file_upload_id => @file_upload.id, :user_id => @who.id, :file_hash => @file_upload.owner)
              @shared.save
            end
        end 
      
        @file_upload.save


        format.html { redirect_to user_file_upload_path(@user,@file_upload), notice: 'File was successfully uploaded.' }
        format.json { render :show, status: :created, location: @file_upload }

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
        @file_path = @file_upload.attachment.path
        @file = File.open(@file_path,"rb")
        @file_contents = @file.read
        @file.close

        @key = ENV['encrypt_hash']
        @enc = AES.encrypt(@file_contents, @key)

        @file = File.open(@file_path,"wb")
        @file.write(@enc)
        @file.close    
        
        @file_upload[:fname] = AES.encrypt(params[:file_upload][:fname], @key)

        @md5 = Digest::MD5.file(@file_upload.attachment.path).hexdigest
        @file_upload[:hash_val]=@md5

        Keyword.where(:file_upload_id =>@file_upload.id).delete_all
        
        @keyword = params[:keywords].split(',')
        @keyword.each do |keyword|
          if keyword.length < 3
            s = gram_fuzzy_set(keyword,0)
          elsif keyword.length < 6
            s = gram_fuzzy_set(keyword,1)
          else
            s = gram_fuzzy_set(keyword,2)
          end
          for i in s
            @keyword_enc = Digest::MD5.hexdigest(i)
            @keywords = Keyword.new(:key => @keyword_enc, :file_upload_id =>@file_upload.id)
            @keywords.save
          end
        end
        if(@file_upload.shared_with=="Private")
          @file_upload[:shared_with] = "Private"

        elsif(@file_upload.shared_with=="Selected Users")
            @users = params[:shared_users].split(',')
            @users.each do |users|
              @who = User.find_by_email(users)
              @shared = SharedUser.new(:user_id => @who.id , :file_upload_id => @file_upload.id)
              @msg = RequestMessage.create(:status_code=>505, :file_upload_id => @file_upload.id, :user_id => @who.id, :file_hash => @file_upload.owner)
              @shared.save
            end

        elsif(@file_upload.shared_with=="Public")
          @file_upload[:shared_with] = "Public"
        
        end 

        @file_upload.save
        format.html { redirect_to user_file_upload_path, notice: 'File was successfully updated.' }
        format.json { render :show, status: :ok, location: @file_upload }
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


  def decrypt
    @file_recv = FileUpload.find_by_id(params[:file_upload_id])
    @file_attachment = @file_recv.attachment
    @file_container = @file_attachment.file
    @file_path = @file_container.path
    @file = File.open(@file_path,"rb")
    @file_contents = @file.read
    @file.close

    @ext = @file_recv.ftype
    @file_path = File.dirname(@file_path)+"/tmp."+@ext

    @key = ENV['encrypt_hash']
    @dec = AES.decrypt(@file_contents, @key)
    
    @file = File.open(@file_path,"wb")
    @file.write(@dec)
    @file.close
    
    
    @file = File.open(@file_path, 'rb')
    @contents = @file.read
    @file.close

    send_data(@contents, :filename => File.basename(@file_path))
    #flash[:success] = "File Downloaded" #Success not flashing
    
    File.delete(@file_path)

    #Send file automatically redirects
    #redirect_to user_file_uploads_path 


    #respond_to do |format|
      #redirect_to (user_file_uploads_path) and return 
      #format.json { head :no_content }
    #end
            
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_file_upload
      @file_upload = FileUpload.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def file_upload_params

      params.require(:file_upload).permit(:fname, :owner, :ftype, :attachment,:shared_with)
    end

    def send_hash_params
      params.require(:request_message).permit(:user_id, :file_upload_id)
    end

    #Function to compute gram based fuzzy set of a keyword
    def gram_fuzzy_set(w,d)
      s = [w]

      for i in 1..d
        for j in 0..s.size-1
          for k in 0..s[j].length-1
            fuzzy = s[j][0..s[j].length-1]
            fuzzy.slice!(k)
            if !s.include?(fuzzy)
              s << fuzzy
            end
          end
        end
      end
      return s
    end

    def encryption_error
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/encrypt_decrypt", :layout => false, :status => :not_found }
      format.xml { head :not_found }
      format.any { head :not_found }
    end
  end
  
end
