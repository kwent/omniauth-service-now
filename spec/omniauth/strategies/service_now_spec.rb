require 'spec_helper'

describe OmniAuth::Strategies::ServiceNow do
  let(:access_token) { instance_double('AccessToken', :options => {}, :[] => 'user') }
  let(:parsed_response) { instance_double('ParsedResponse') }
  let(:response) { instance_double('Response', :parsed => parsed_response) }

  let(:enterprise_site)          { 'https://some.other.site.com' }
  let(:enterprise_authorize_url) { 'https://some.other.site.com/login/oauth/authorize' }
  let(:enterprise_token_url)     { 'https://some.other.site.com/login/oauth/token' }
  let(:enterprise) do
    OmniAuth::Strategies::ServiceNow.new('SERVICE_NOW_CLIENT_ID', 'SERVICE_NOW_CLIENT_SECRET',
        {
            :client_options => {
                :site => enterprise_site,
                :authorize_url => enterprise_authorize_url,
                :token_url => enterprise_token_url
            }
        }
    )
  end

  subject do
    OmniAuth::Strategies::ServiceNow.new({})
  end

  before(:each) do
    allow(subject).to receive(:access_token).and_return(access_token)
  end

  context 'client options' do
    it 'should have correct site' do
      expect(subject.options.client_options.site).to eq('https://<instance-id>.service-now.com')
    end

    it 'should have correct authorize url' do
      expect(subject.options.client_options.authorize_url).to eq('/oauth_auth.do')
    end

    it 'should have correct token url' do
      expect(subject.options.client_options.token_url).to eq('/oauth_token.do')
    end

    describe 'should be overrideable' do
      it 'for site' do
        expect(enterprise.options.client_options.site).to eq(enterprise_site)
      end

      it 'for authorize url' do
        expect(enterprise.options.client_options.authorize_url).to eq(enterprise_authorize_url)
      end

      it 'for token url' do
        expect(enterprise.options.client_options.token_url).to eq(enterprise_token_url)
      end
    end
  end

  describe '#callback_url' do
    let(:base_url) { 'https://example.com' }

    context 'no script name present' do
      it 'has the correct default callback path' do
        allow(subject).to receive(:full_host) { base_url }
        allow(subject).to receive(:script_name) { '' }
        allow(subject).to receive(:query_string) { '' }
        expect(subject.callback_url).to eq(base_url + '/auth/service_now/callback')
      end
    end

    context 'script name' do
      it 'should set the callback path with script_name' do
        allow(subject).to receive(:full_host) { base_url }
        allow(subject).to receive(:script_name) { '/v1' }
        allow(subject).to receive(:query_string) { '' }
        expect(subject.callback_url).to eq(base_url + '/v1/auth/service_now/callback')
      end
    end
  end
end
