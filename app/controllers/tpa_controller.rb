class TpaController < ApplicationController
  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
    @req = RequestMessage.find_by_id(params[:id])
    @req.destroy
    redirect_to tpa_index_path
  end

  def audit
  end
  def index
    @user = User.find_by_id(1)
    @req = RequestMessage.all
    
  end
  def show
    @user = User.find(params[:id])
    @req = RequestMessage.all
  end

end
