
#
# Specifying fugit
#
# Sun Aug 20 06:58:44 JST 2017
#

require 'spec_helper'


describe Dense::Path do

  describe '#walk' do

    before :all do

      @data =
        { 'store' => {
            'book' => [
              { 'category' => 'reference',
                'author' => 'Nigel Rees',
                'title' => 'Sayings of the Century',
                'price' => 8.95
              },
              { 'category' => 'fiction',
                'author' => 'Evelyn Waugh',
                'title' => 'Sword of Honour',
                'price' => 12.99
              },
              { 'category' => 'fiction',
                'author' => 'Herman Melville',
                'title' => 'Moby Dick',
                'isbn' => '0-553-21311-3',
                'price' => 8.99
              },
              { 'category' => 'fiction',
                'author' => 'J. R. R. Tolkien',
                'title' => 'The Lord of the Rings',
                'isbn' => '0-395-19395-8',
                'price' => 22.99
              }
            ],
            'bicycle' => {
              'color' => 'red',
              'price' => 19.95
            }
          }
        }
    end

    {

      'store.bicycle.color' => 'red',
      'store.bicycle.price' => 19.95,

    }.each do |path, result|

      it "walks #{path.inspect}" do

        pa = Dense::Path.new(path)

        expect(pa).not_to eq(nil)
        expect(pa.walk(@data)).to eq(result)
      end
    end
  end
end

