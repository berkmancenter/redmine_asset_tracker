require_dependency 'project'
require_dependency 'principal'
require_dependency 'user'

module UserPatch
  def self.included(base) 
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      #unloadable # Send unloadable so it will not be unloaded in development
      has_many :favourites, :dependent => :destroy
      
    end

  end
  
  module ClassMethods
    
  end
  
  module InstanceMethods
  end

end

User.send(:include, UserPatch)