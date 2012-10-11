class SkyDB
  class Client
    ##########################################################################
    #
    # Constants
    #
    ##########################################################################

    # The default host to connect to if one is not specified.
    DEFAULT_HOST = 'localhost'

    # The default port to connect to if one is not specified.
    DEFAULT_PORT = 8585


    ##########################################################################
    #
    # Constructor
    #
    ##########################################################################

    # Initializes the client.
    def initialize(options={})
      self.host = options[:host] || DEFAULT_HOST
      self.port = options[:port] || DEFAULT_PORT
    end


    ##########################################################################
    #
    # Attributes
    #
    ##########################################################################

    # The name of the host to conect to.
    attr_accessor :host

    # The port on the host to connect to.
    attr_accessor :port

    # The database to connect to.
    attr_accessor :database

    # The table to connect to.
    attr_accessor :table


    ##########################################################################
    #
    # Methods
    #
    ##########################################################################
    
    ####################################
    # Action Messages
    ####################################

    # Adds an action to the server.
    #
    # @param [Action] action  the action to add.
    def aadd(action, options={})
      return send_message(SkyDB::Message::AADD.new(action, options))
    end

    # Retrieves an individual action from the server.
    #
    # @param [Fixnum] action_id  the identifier of the action to retrieve.
    def aget(action_id, options={})
      return send_message(SkyDB::Message::AGET.new(action_id, options))
    end

    # Retrieves a list of all actions from the server.
    def aall(options={})
      return send_message(SkyDB::Message::AALL.new(options))
    end


    ####################################
    # Property Messages
    ####################################

    # Adds a property to the server.
    #
    # @param [Property] property  the property to add.
    def padd(property, options={})
      return send_message(SkyDB::Message::PADD.new(property, options))
    end

    # Retrieves an individual property from the server.
    #
    # @param [Fixnum] property_id  the identifier of the property to retrieve.
    def pget(property_id, options={})
      return send_message(SkyDB::Message::PGET.new(property_id, options))
    end

    # Retrieves a list of all properties from the server.
    def pall(options={})
      return send_message(SkyDB::Message::PALL.new(options))
    end


    ####################################
    # Event Messages
    ####################################

    # Adds an event to the server.
    #
    # @param [Event] event  the event to add.
    def eadd(event, options={})
      return send_message(SkyDB::Message::EADD.new(event, options))
    end


    ####################################
    # Path Messages
    ####################################

    # Executes a query against each path on the server.
    #
    # @param [String] query  the query to execute.
    def peach(query, options={})
      return send_message(SkyDB::Message::PEACH.new(query, options))
    end
    

    ####################################
    # Send
    ####################################

    # Sends a message to the server.
    #
    # @param [SkyDB::Message] message  the message to send.
    # @return [Object]  the object returned by the server.
    def send_message(message)
      # Set the database and table if they're not set.
      message.database = database if message.database.nil? || message.database.empty?
      message.table = table if message.table.nil? || message.table.empty?

      # Validate message before sending.
      message.validate!
      
      # Connect to the server.
      socket = TCPSocket.new(host, port.to_i)
      
      # Encode and send message request.
      message.encode(socket)
      
      # Decode msgpack response. There should only be one return object.
      response = nil
      unpacker = MessagePack::Unpacker.new(socket)
      unpacker.each do |obj|
        response = obj
        break
      end
      
      # Close socket.
      socket.close()
      
      # TODO: Exception processing.
      
      # Process response back through the message.
      response = message.process_response(response)
      
      # Return response.
      return response
    end
  end
end