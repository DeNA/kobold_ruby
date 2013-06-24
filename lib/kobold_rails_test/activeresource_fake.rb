module TestHelpers::ActiveResourceFake
  include RDouble

  class ActiveResourceFake
    @@instance_lookup = {}
    @@next_id_lookup = {}

    def self.get_next_id(klass)
      current_id = @@next_id_lookup[klass]
      @@next_id_lookup[klass] += 1
      return current_id
    end

    def self.find_every(this, *args)
      self.fill_lookup(this)
      params = args[0][:params]
      to_return = @@instance_lookup[this][:id].values
      params.each do |k, v|
        to_return = to_return.select {|instance| instance.send(k) == v}
      end
      return to_return
    end

    def self.find_one(this, *args)
      raise Exception.new("Not Implemented")
    end

    def self.find_attributes(this)
      return []
    end

    def self.find_single(this, *args)
      self.fill_lookup(this)
      id = args[0]
      result = @@instance_lookup[this][:id][id.to_i]
      if !result.nil?
        return result
      end
      this.find_attributes.each do |attribute|
        result = self.find_every(this, :params => {attribute => id})
        if !result.empty?
          return result[0]
        end
      end
      return nil
    end

    def self.update(this, *args)
      raise Exception.new("Not Implemented")
    end

    def self.create(this, *args)
      fill_lookup(this.class)
      current_id = get_next_id(this.class)
      this.attributes[:id] = current_id
      self.add_instance(this, this.attributes)
    end

    def self.add_instance(this, attributes)
      fill_lookup(this)
      @@instance_lookup[this.class][:id][attributes[:id]] = this
      return this
    end

    def self.fill_lookup(subject)
      if subject.class == Class
        klass = subject
      else
        klass = subject.class
      end

      if @@next_id_lookup[klass].nil?
        @@next_id_lookup[klass] = 1
      end

      if @@instance_lookup.nil?
        @@instance_lookup = {}
      end

      if @@instance_lookup[klass].nil?
        @@instance_lookup[klass] = {}
      end

      if @@instance_lookup[klass][:id].nil?
        @@instance_lookup[klass][:id] = {}
      end
    end

    def self.reset
      @@instance_lookup = {}
      @@next_id_lookup = {}
    end
  end

  def install_activeresource_fake
    swap_double(ActiveResource::Base, :find_one, ActiveResourceFake.method(:find_one))
    swap_double(ActiveResource::Base, :find_every, ActiveResourceFake.method(:find_every))
    swap_double(ActiveResource::Base, :find_single, ActiveResourceFake.method(:find_single))
    swap_double(ActiveResource::Base, :create, ActiveResourceFake.method(:create), :all_instances => true)
    swap_double(ActiveResource::Base, :update, ActiveResourceFake.method(:update), :all_instances => true) 
    add_function(ActiveResource::Base, :find_attributes, ActiveResourceFake.method(:find_attributes))
  end

  def uninstall_activeresource_fake
    unswap_doubles(:subject => ActiveResource::Base)
  end

  def setup
    install_activeresource_fake
    super
  end

  def teardown
    ActiveResourceFake.reset
    uninstall_activeresource_fake
    super
  end
end
