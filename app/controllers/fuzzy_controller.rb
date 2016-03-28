class FuzzyController < ApplicationController
  def fuzzy_search

    @keywords = params[:search].split()
    @keywords.map!(&:downcase)
    @keyword_fuzz = []
    #removing stop words and converting keywords to their base form 
    @stopwords = ["a","and","the","or","is","was","you","i","to","so","but","in","all"]
    @keyword=@keywords.reject {|term| @stopwords.include? term}
    @keyword.each do |keyword|
      if(keyword.end_with? 'ed')
          keyword.chomp!("ed")
      elsif (keyword.end_with? 'ing')
          keyword.chomp!("ing")
      end
      #computing fuzzies of query set
      if keyword.length < 3
        s = gram_fuzzy_set(keyword,0)
      elsif keyword.length < 6
        s = gram_fuzzy_set(keyword,1)
      else
        s = gram_fuzzy_set(keyword,2)
      end
      for i in s
        @keyword_enc = Digest::MD5.hexdigest(i)
        @keyword_fuzz << @keyword_enc
      end
    end
    @my_keywords = []
    @keyword_fuzz.each do |key|
    	@temps = Keyword.where(:key => key)
    	@my_keywords << @temps
    end
    @file_ids = []
    @my_keywords.each do |record|
    	record.each do |rec|
    		@file_ids << rec.file_upload_id
    	end
    end
    @file_ids = @file_ids.uniq
    redirect_to fuzzy_authorize_path(:userid => params[:tab], :files => @file_ids, :search => params[:search])#, :keyword_fuzz => @keyword_fuzz)  
    
  end

  def authorize
  	@user = User.find_by_id(params[:userid])
    @keyword_fuzz = []
    @keywords = params[:search].split()
    #removing stop words and converting keywords to their base form 
    @stopwords = ["a","and","the","or","is","was","you","i","to","so","but","in","all"]
    @keyword=@keywords.reject {|term| @stopwords.include? term}
    @keyword.each do |keyword|
      if(keyword.end_with? 'ed')
          keyword.chomp!("ed")
      elsif (keyword.end_with? 'ing')
          keyword.chomp!("ing")
      end
      #computing fuzzies of query set for ranking
      if keyword.length < 3
        s = gram_fuzzy_set(keyword,0)
        elsif keyword.length < 6
          s = gram_fuzzy_set(keyword,1)
        else
          s = gram_fuzzy_set(keyword,2)
      end
      for i in s
        @keyword_enc = Digest::MD5.hexdigest(i)
        @keyword_fuzz << @keyword_enc
      end
    end
    
  	@file_ids = params[:files]
    @keywords_recs = []
    if(@file_ids)
      @file_ids.each do |file|
        @keywords_recs << Keyword.where(:file_upload_id => file)
      end
    end
    #Ranking...
    file = {}
    max = 0
    @keywords_recs.each do |keyword_rec|
      count = 0
      file_id = 0
      keyword_rec.each do |keyword1|
        file_id = keyword1.file_upload_id
        
        @keyword_fuzz.each do |keyword|
          if keyword == keyword1.key 
            count = count + 1
          end
        end        
      end
      file [file_id] = count
    end
    @file_ids = []
    file = file.sort_by{|file_id,count| count}
    file = file.reverse
    file.each do |f|
      @file_ids << f[0]
    end
    #authorising users
  	@file_recs = []
  	if (@file_ids) 
  		@file_ids.each do |file_id|

  		  @temps = FileUpload.find(file_id)
        if(@user.id==@temps.user_id or @temps.shared_with == "Public")
          @file_recs << @temps
        
        elsif(@temps.shared_with=="Selected Users")
          @sel_user = SharedUser.where(:file_upload_id => file_id, :user_id =>@user.id)
          if(@sel_user)
            @file_recs << @temps
          end
        end
      end
       
    end
    #classifying search results
    @image_files = ["jpg","png","jpeg","bmp"]
    @presentation_files = ["odp","ppt"]
    @video_files = ["mp4","3gp"]
    @office_files = ["doc","odt"]

    @image_count = 0
    @presentation_count = 0
    @video_count = 0
    @office_count = 0
    @pdf_count = 0
    @other_count = 0

    @file_recs.each do |file| 
      if(file.ftype=="pdf")
        @pdf_count = @pdf_count+1
        
      elsif @image_files.include? file.ftype
        @image_count = @image_count+1
      elsif @presentation_files.include? file.ftype
        @presentation_count = @presentation_count+1
      elsif @office_files.include? file.ftype

        @office_count = @office_count+1
      elsif @video_files.include? file.ftype
        @video_count = @video_count+1
      else 
        @other_count = @other_count+1
      end
    end
    @max=[@pdf_count,@image_count,@office_count,@presentation_count,@video_count,@other_count].max
    @open=0
  end

  def audit
    @user = User.find(params[:user_id])
    @id1 = params[:user_id]
    @file_uploads = FileUpload.find_by_id(params[:file_upload_id])
    @md5 = Digest::MD5.file(@file_uploads.attachment.path).hexdigest 
    @message = RequestMessage.create(:status_code=>503, :file_upload_id=>@file_uploads[:id], :user_id=>@id1)
    flash[:success] = "Audit Request Sent"
    #raise
    redirect_to fuzzy_authorize_path(:search => params[:search],:userid => params[:user_id], :files => params[:files])

  end

  private

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

end
