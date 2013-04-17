require 'test_helper'

describe "RailsUtils::ActionViewExtensions" do
  let(:controller)  { ActionController::Base.new }
  let(:request)     { ActionDispatch::Request.new(flash: {}) }
  let(:view)        { ActionView::Base.new }

  before do
    controller.request = request
    view.controller    = controller
  end

  describe "#page_class" do
    # controller_name, action_name, expected
    [
      [ "anime", "index"  , "anime index"   ],
      [ "anime", "show"   , "anime show"    ],
      [ "anime", "new"    , "anime new"     ],
      [ "anime", "create" , "anime new"     ],
      [ "anime", "edit"   , "anime edit"    ],
      [ "anime", "update" , "anime edit"    ],
      [ "anime", "destroy", "anime destroy" ],
      [ "anime", "custom" , "anime custom"  ],
    ].each do |controller_name, action_name, expected|
      describe "when #{controller_name} and #{action_name}" do
        before do
          controller.stubs(:controller_name).returns(controller_name)
          controller.stubs(:action_name).returns(action_name)
        end

        it "returns #{expected}" do
           view.page_class.must_equal expected
        end
      end
    end
  end

  describe "#javascript_initialization" do
    let(:controller_name) { "anime" }

    before do
      controller.stubs(:controller_name).returns(controller_name)
      controller.stubs(:action_name).returns(action_name)
    end

    describe "when controller name and action name are standard" do
      let(:action_name)     { "custom" }

      it "invokes application" do
        view.javascript_initialization.must_match "Dummy.init();"
      end

      it "invokes controller and action javascript" do
        view.javascript_initialization.must_match "Dummy.#{controller_name}.init();"
        view.javascript_initialization.must_match "Dummy.#{controller_name}.init_#{action_name}();"
      end
    end

    describe "when action name is create" do
      let(:action_name)     { "create" }

      it "replaces create with new" do
        view.javascript_initialization.must_match "Dummy.#{controller_name}.init_new();"
      end
    end

    describe "when action name is update" do
      let(:action_name)     { "update" }

      it "replaces update with create" do
        view.javascript_initialization.must_match "Dummy.#{controller_name}.init_edit();"
      end
    end
  end

  describe "#flash_messages" do
    def set_flash(key, message)
      controller.flash[key] = message
    end

    [
      [ :success , /alert alert-success/, "flash is success" ],
      [ :notice  , /alert alert-info/   , "flash is notice"  ],
      [ :error   , /alert alert-error/  , "flash is error"   ],
      [ :alert   , /alert alert-error/  , "flash is alert"   ],
      [ :custom  , /alert alert-custom/ , "flash is custom"  ],
    ].each do |key, expected_class, expected_message|
      describe "when flash contains #{key} key" do
        before { set_flash key, expected_message }

        it "prints class '#{expected_class}'" do
          view.flash_messages.must_match expected_class
        end

        it "prints message '#{expected_message}'" do
          view.flash_messages.must_match expected_message
        end
      end
    end

    describe "when bootstrap is present" do
      it "can fade in and out" do
        set_flash :alert  , "not important"
        view.flash_messages.must_match /fade in/
      end

      it "can be dismissed" do
        set_flash :alert  , "not important"
        view.flash_messages.must_match /data-dismiss-alert=.*alert/
      end
    end
  end
end