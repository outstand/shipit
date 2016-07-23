require 'shipitron/docker_image'

describe Shipitron::DockerImage do
  let(:name) { 'super' }
  let(:tag) { 'e459bf914378' }
  let(:docker_image) do
    Shipitron::DockerImage.new(
      name: name,
      tag: tag
    )
  end

  describe '#name_with_tag' do
    context 'without a tag override' do
      it 'returns the specific tag' do
        expect(docker_image.name_with_tag).to eq "#{name}:#{tag}"
      end
    end

    context 'with an override tag' do
      it 'returns the override tag' do
        expect(docker_image.name_with_tag('latest')).to eq "#{name}:latest"
      end
    end

    context 'without a specific tag' do
      let(:tag) { nil }

      context 'without an override tag' do
        it 'returns just the name' do
          expect(docker_image.name_with_tag).to eq name
        end
      end

      context 'with an override tag' do
        it 'returns the override tag' do
          expect(docker_image.name_with_tag('latest')).to eq "#{name}:latest"
        end
      end
    end
  end
end
