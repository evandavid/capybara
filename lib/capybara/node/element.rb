module Capybara
  module Node

    ##
    #
    # A {Capybara::Element} represents a single element on the page. It is possible
    # to interact with the contents of this element the same as with a document:
    #
    #     session = Capybara::Session.new(:rack_test, my_app)
    #
    #     bar = session.find('#bar')              # from Capybara::Node::Finders
    #     bar.select('Baz', :from => 'Quox')      # from Capybara::Node::Actions
    #
    # {Capybara::Element} also has access to HTML attributes and other properties of the
    # element:
    #
    #      bar.value
    #      bar.text
    #      bar[:title]
    #
    # @see Capybara::Node
    #
    class Element < Base

      def initialize(session, base, parent, query)
        super(session, base)
        @parent = parent
        @query = query
      end

      def allow_reload!
        @allow_reload = true
      end

      ##
      #
      # @return [Object]    The native element from the driver, this allows access to driver specific methods
      #
      def native
        synchronize { base.native }
      end

      ##
      #
      # Retrieve the text of the element. If `Capybara.ignore_hidden_elements`
      # is `true`, which it is by default, then this will return only text
      # which is visible. The exact semantics of this may differ between
      # drivers, but generally any text within elements with `display:none` is
      # ignored. This behaviour can be overridden by passing `:all` to this
      # method.
      #
      # @param [:all, :visible] type  Whether to return only visible or all text
      # @return [String]              The text of the element
      #
      def text(type=nil)
        type ||= :all unless Capybara.ignore_hidden_elements or Capybara.visible_text_only
        synchronize do
          if type == :all
            base.all_text
          else
            base.visible_text
          end
        end
      end

      ##
      #
      # Retrieve the given attribute
      #
      #     element[:title] # => HTML title attribute
      #
      # @param  [Symbol] attribute     The attribute to retrieve
      # @return [String]               The value of the attribute
      #
      def [](attribute)
        synchronize { base[attribute] }
      end

      ##
      #
      # @return [String]    The value of the form element
      #
      def value
        synchronize { base.value }
      end

      ##
      #
      # Set the value of the form element to the given value.
      #
      # @param [String] value    The new value
      # @param [Hash{}] options  Driver specific options for how to set the value
      #
      def set(value, options={})
        options ||= {}
        
        driver_supports_options = (base.method(:set).arity != 1)

        unless options.empty? || driver_supports_options 
          warn "Options passed to Capybara::Node#set but the driver doesn't support them"
        end

        synchronize do
          if driver_supports_options
            base.set(value, options)
          else
            base.set(value)
          end
        end
      end

      ##
      #
      # Select this node if is an option element inside a select tag
      #
      def select_option
        synchronize { base.select_option }
      end

      ##
      #
      # Unselect this node if is an option element inside a multiple select tag
      #
      def unselect_option
        synchronize { base.unselect_option }
      end

      ##
      #
      # Click the Element
      #
      def click
        synchronize { base.click }
      end

      ##
      #
      # Right Click the Element
      #
      def right_click
        synchronize { base.right_click }
      end

      ##
      #
      # Double Click the Element
      #
      def double_click
        synchronize { base.double_click }
      end
      
      ##
      #
      # Send Keystrokes to the Element
      #
      # @param [String, Symbol, Array]
      #
      # Examples:
      #
      #     element.send_keys "foo"                     #=> value: 'foo'
      #     element.send_keys "tet", :arrow_left, "s"   #=> value: 'test'
      #     element.send_keys [:control, 'a'], :space   #=> value: ' '
      #
      # Symbols supported for keys
      # :null         => "\xEE\x80\x80"
      # :cancel       => "\xEE\x80\x81"
      # :help         => "\xEE\x80\x82"
      # :backspace    => "\xEE\x80\x83"
      # :tab          => "\xEE\x80\x84"
      # :clear        => "\xEE\x80\x85"
      # :return       => "\xEE\x80\x86"
      # :enter        => "\xEE\x80\x87"
      # :shift        => "\xEE\x80\x88"
      # :left_shift   => "\xEE\x80\x88"
      # :control      => "\xEE\x80\x89"
      # :left_control => "\xEE\x80\x89"
      # :alt          => "\xEE\x80\x8A"
      # :left_alt     => "\xEE\x80\x8A"
      # :pause        => "\xEE\x80\x8B"
      # :escape       => "\xEE\x80\x8C"
      # :space        => "\xEE\x80\x8D"
      # :page_up      => "\xEE\x80\x8E"
      # :page_down    => "\xEE\x80\x8F"
      # :end          => "\xEE\x80\x90"
      # :home         => "\xEE\x80\x91"
      # :left         => "\xEE\x80\x92"
      # :arrow_left   => "\xEE\x80\x92"
      # :up           => "\xEE\x80\x93"
      # :arrow_up     => "\xEE\x80\x93"
      # :right        => "\xEE\x80\x94"
      # :arrow_right  => "\xEE\x80\x94"
      # :down         => "\xEE\x80\x95"
      # :arrow_down   => "\xEE\x80\x95"
      # :insert       => "\xEE\x80\x96"
      # :delete       => "\xEE\x80\x97"
      # :semicolon    => "\xEE\x80\x98"
      # :equals       => "\xEE\x80\x99"
      # :numpad0      => "\xEE\x80\x9A"
      # :numpad1      => "\xEE\x80\x9B"
      # :numpad2      => "\xEE\x80\x9C"
      # :numpad3      => "\xEE\x80\x9D"
      # :numpad4      => "\xEE\x80\x9E"
      # :numpad5      => "\xEE\x80\x9F"
      # :numpad6      => "\xEE\x80\xA0"
      # :numpad7      => "\xEE\x80\xA1"
      # :numpad8      => "\xEE\x80\xA2"
      # :numpad9      => "\xEE\x80\xA3"
      # :multiply     => "\xEE\x80\xA4"
      # :add          => "\xEE\x80\xA5"
      # :separator    => "\xEE\x80\xA6"
      # :subtract     => "\xEE\x80\xA7"
      # :decimal      => "\xEE\x80\xA8"
      # :divide       => "\xEE\x80\xA9"
      # :f1           => "\xEE\x80\xB1"
      # :f2           => "\xEE\x80\xB2"
      # :f3           => "\xEE\x80\xB3"
      # :f4           => "\xEE\x80\xB4"
      # :f5           => "\xEE\x80\xB5"
      # :f6           => "\xEE\x80\xB6"
      # :f7           => "\xEE\x80\xB7"
      # :f8           => "\xEE\x80\xB8"
      # :f9           => "\xEE\x80\xB9"
      # :f10          => "\xEE\x80\xBA"
      # :f11          => "\xEE\x80\xBB"
      # :f12          => "\xEE\x80\xBC"
      # :meta         => "\xEE\x80\xBD"
      # :command      => "\xEE\x80\xBD"
      #
      def send_keys(*args)
        synchronize { base.send_keys(*args) }
      end

      ##
      #
      # Hover on the Element
      #
      def hover
        synchronize { base.hover }
      end

      ##
      #
      # @return [String]      The tag name of the element
      #
      def tag_name
        synchronize { base.tag_name }
      end

      ##
      #
      # Whether or not the element is visible. Not all drivers support CSS, so
      # the result may be inaccurate.
      #
      # @return [Boolean]     Whether the element is visible
      #
      def visible?
        synchronize { base.visible? }
      end

      ##
      #
      # Whether or not the element is checked.
      #
      # @return [Boolean]     Whether the element is checked
      #
      def checked?
        synchronize { base.checked? }
      end

      ##
      #
      # Whether or not the element is selected.
      #
      # @return [Boolean]     Whether the element is selected
      #
      def selected?
        synchronize { base.selected? }
      end

      ##
      #
      # Whether or not the element is disabled.
      #
      # @return [Boolean]     Whether the element is disabled
      #
      def disabled?
        synchronize { base.disabled? }
      end

      ##
      #
      # An XPath expression describing where on the page the element can be found
      #
      # @return [String]      An XPath expression
      #
      def path
        synchronize { base.path }
      end

      ##
      #
      # Trigger any event on the current element, for example mouseover or focus
      # events. Does not work in Selenium.
      #
      # @param [String] event       The name of the event to trigger
      #
      def trigger(event)
        synchronize { base.trigger(event) }
      end

      ##
      #
      # Drag the element to the given other element.
      #
      #     source = page.find('#foo')
      #     target = page.find('#bar')
      #     source.drag_to(target)
      #
      # @param [Capybara::Element] node     The element to drag to
      #
      def drag_to(node)
        synchronize { base.drag_to(node.base) }
      end

      def reload
        if @allow_reload
          begin
            reloaded = parent.reload.first(@query.name, @query.locator, @query.options)
            @base = reloaded.base if reloaded
          rescue => e
            raise e unless catch_error?(e)
          end
        end
        self
      end

      def inspect
        %(#<Capybara::Element tag="#{tag_name}" path="#{path}">)
      rescue NotSupportedByDriverError
        %(#<Capybara::Element tag="#{tag_name}">)
      end
    end
  end
end
