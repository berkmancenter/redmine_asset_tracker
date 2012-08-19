# @author Nitish Upreti
class FavouritesController < PluginController
  unloadable

  # Lists all the [Favourite] from the Database
  def index 
  	@user = User.find_by_id session[:user_id]

    #no user signed up gives us a nil
    unless @user then
        render 'index'
        return
    end

    @assets, @asset_groups = populate_asset_list

  end

  #Mark an [Asset] or [AssetGroup] as favourite
  def mark_as_favourite

  	@user = User.find_by_id session[:user_id]
  	@favourites=@user.favourites

    #Find if the item is already a favourite
	  fav=Favourite.where(:item_id => params[:id], :item_type => params[:type], :user_id => session[:user_id])
	
    #unless we have an empty record
	  unless fav.empty? then
	   	#un-favourite
		  fav.first.destroy
	  else
		  #make it a favourite
		  fav=Favourite.new
		  fav.item_id=params[:id]
		  fav.item_type=params[:type]
		  fav.user_id=session[:user_id]
		  fav.save
    end

    respond_to do |format|
      format.js { render "mark_as_favourite", :locals => {:id => params[:id], :type => params[:type]} }
    end

  end

end