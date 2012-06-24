require_dependency 'project'
require_dependency 'principal'
require_dependency 'user'

module UserPatch
  def self.included(base) 
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    base.unloadable 

    base.has_many :favourites, :dependent => :destroy
  end
  
  module ClassMethods
    
  end
  
  module InstanceMethods
  end

end

User.send(:include, UserPatch)