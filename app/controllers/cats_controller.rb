class CatsController < ApplicationController
  before_action :set_cat, only: [:show, :edit, :update, :destroy]

  def index
    @cats = Cat.all.order(:category, :name)
  end

  def new
    @cat = Cat.new
  end

  def create
    @cat = Cat.new(cat_params)
    if @cat.save
      redirect_to cats_path, notice: 'Cat model was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @cat.update(cat_params)
      redirect_to cats_path, notice: 'Cat model was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @cat.destroy
    redirect_to cats_url, notice: 'Cat model was successfully deleted.'
  end

  private

  def set_cat
    @cat = Cat.find(params[:id])
  end

  def cat_params
    params.require(:cat).permit(:name, :model_filename, :category, :customizable)
  end
end
