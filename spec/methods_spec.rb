
#
# Specifying dense
#
# Tue Sep  5 17:35:03 JST 2017
#

require 'spec_helper'


describe Dense do

    before :all do

      @data = # taken from http://goessner.net/articles/JsonPath/
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

  describe '.get' do

    [

      [ 'store.book.1.title',
        'Sword of Honour' ],
      [ 'store.book.*.title',
        [ 'Sayings of the Century', 'Sword of Honour', 'Moby Dick',
          'The Lord of the Rings'] ],

    ].each do |path, result|

      it "gets #{path.inspect}" do

        expect(Dense.get(@data, path)).to eq(result)
      end
    end
  end
end

