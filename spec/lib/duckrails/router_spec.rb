require 'rails_helper'

module Duckrails
  RSpec.describe Router do
    it 'should have default methods' do
      expect(Router::METHODS).to eq [:get, :post, :put, :patch, :delete, :options, :head]
    end

    describe '::REGISTERED_MOCKS' do
      context 'without mocks' do
        it 'should not have registered mocks' do
          expect(Router::REGISTERED_MOCKS).to be_empty
        end
      end

      context 'with mocks' do
        before do
          3.times do |i|
            FactoryGirl.create(:mock, id: i,
                                      name: "Mock:#{i}",
                                      route_path: "/router/#{i}")
          end
        end

        it 'should include the existing mocks' do
          expect(Router::REGISTERED_MOCKS).to eq([0, 1, 2])
        end
      end
    end

    describe '.register_mock' do
      let(:mock) { FactoryGirl.build(:mock, id: '1') }

      it 'should add the mock in the registered mocks' do
        expect{Router.register_mock(mock)}.to change{ Router::REGISTERED_MOCKS.size }.from(0).to(1)
      end

      it 'should not keep duplicates' do
        expect{Router.register_mock(mock)}.to change{ Router::REGISTERED_MOCKS.size }.from(0).to(1)
        expect{Router.register_mock(mock)}.not_to change{ Router::REGISTERED_MOCKS.size }
      end
    end

    describe '.register_current_mocks' do
      before do
        expect(Duckrails::Mock).to receive(:pluck).with(:id).and_return([1, 2, 3])
      end

      it 'should register existing mocks' do
        expect{Router.register_current_mocks}.to change{Router::REGISTERED_MOCKS.size}.from(0).to(3)
        expect(Router::REGISTERED_MOCKS).to eq [1, 2, 3]
      end
    end

    describe '.unregister_mock' do
      let(:mock) { FactoryGirl.build :mock, id: 1 }
      before do
        expect(Duckrails::Mock).to receive(:pluck).with(:id).and_return([1, 2, 3])
        Router.register_current_mocks
      end

      it 'should unregister the mocks' do
        expect(Router::REGISTERED_MOCKS).to eq [1, 2, 3]
        expect{Router::unregister_mock(mock)}.to change{Router::REGISTERED_MOCKS.size}.from(3).to(2)
        expect(Router::REGISTERED_MOCKS).to eq [2, 3]
      end
    end

    describe '.load_mock_routes!' do
      before do
        expect(Duckrails::Mock).to receive(:pluck).with(:id).and_return([1, 2, 3])
        Router.register_current_mocks
      end

      it 'should define routes for current mocks' do
        expect(Router).to receive(:define_route).with(1)
        expect(Router).to receive(:define_route).with(2)
        expect(Router).to receive(:define_route).with(3)

        Router.load_mock_routes!
      end
    end

    describe '#protected .define_route(mock_id)' do
      let(:active) { nil }
      let(:mock) { FactoryGirl.build(:mock, id: 1, active: active) }

      before do
        expect(Duckrails::Mock).to receive(:find).with(1).and_return(mock)
      end

      context 'for active mock' do
        let(:active) { true }

        it 'should create the route' do
          allow_any_instance_of(ActionDispatch::Routing::Mapper).to receive(:match)
          allow_any_instance_of(ActionDispatch::Routing::Mapper).to receive(:match).with(mock.route_path,
                                                                                    to: 'duckrails/mocks#serve_mock',
                                                                                    defaults: {
                                                                                      duckrails_mock_id: 1
                                                                                    },
                                                                                    via: mock.request_method).and_raise('CALLED')

          expect{Router.send(:define_route, 1)}.to raise_error(/CALLED/)
        end
      end

      context 'for inactive mock' do
        let(:active) { false }

        it 'should create the route' do
          allow_any_instance_of(ActionDispatch::Routing::Mapper).to receive(:match)
          allow_any_instance_of(ActionDispatch::Routing::Mapper).to receive(:match).with(mock.route_path,
                                                                                    to: 'duckrails/mocks#serve_mock',
                                                                                    defaults: {
                                                                                      duckrails_mock_id: 1
                                                                                    },
                                                                                    via: mock.request_method).and_raise('CALLED')

          expect{Router.send(:define_route, 1)}.not_to raise_error
        end
      end
    end
  end
end