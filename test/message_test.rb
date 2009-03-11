
require 'helper'

class MessageTest < RSolrBaseTest
  
  # call all of the simple methods...
  # make sure the xml string is valid
  # ensure the class is actually Solr::XML
  def test_simple_methods
    [:optimize, :rollback, :commit].each do |meth|
      result = RSolr::Message.send(meth)
      assert_equal "<#{meth}/>", result.to_s
      assert_equal String, result.class
    end
  end
  
  def test_add_yields_field_attrs_if_block_given
    result = RSolr::Message.add({:id=>1}, :boost=>200.00) do |hash_doc, doc_xml_attrs|
      doc_xml_attrs[:boost] = 10
    end
    assert result =~ /add boost="200.0"/
    assert result =~ /boost="10"/
    #assert_equal '<add boost="200.0"><doc><field name="id" boost="10">1</field></doc></add>', result
  end
  
  def test_delete_by_id
    result = RSolr::Message.delete_by_id(10)
    assert_equal String, result.class
    assert_equal '<delete><id>10</id></delete>', result.to_s
  end
  
  def test_delete_by_multiple_ids
    result = RSolr::Message.delete_by_id([1, 2, 3])
    assert_equal String, result.class
    assert_equal '<delete><id>1</id><id>2</id><id>3</id></delete>', result.to_s
  end
  
  def test_delete_by_query
    result = RSolr::Message.delete_by_id('status:"LOST"')
    assert_equal String, result.class
    assert_equal '<delete><id>status:"LOST"</id></delete>', result.to_s
  end
  
  def test_delete_by_multiple_queries
    result = RSolr::Message.delete_by_id(['status:"LOST"', 'quantity:0'])
    assert_equal String, result.class
    assert_equal '<delete><id>status:"LOST"</id><id>quantity:0</id></delete>', result.to_s
  end
  
  # add a single hash ("doc")
  def test_add_hash
    data = {
      :id=>1,
      :name=>'matt'
    }
    assert RSolr::Message.add(data).to_s =~ /<field name="name">matt<\/field>/
    assert RSolr::Message.add(data).to_s =~ /<field name="id">1<\/field>/
  end
  
  # add an array of hashes
  def test_add_array
    data = [
      {
        :id=>1,
        :name=>'matt'
      },
      {
        :id=>2,
        :name=>'sam'
      }
    ]
    
    message = RSolr::Message.add(data)
    expected = '<add><doc><field name="id">1</field><field name="name">matt</field></doc><doc><field name="id">2</field><field name="name">sam</field></doc></add>'
    
    assert message.to_s=~/<field name="name">matt<\/field>/
    assert message.to_s=~/<field name="name">sam<\/field>/
  end
  
  # multiValue field support test, thanks to Fouad Mardini!
  def test_add_multi_valued_field
    data = {
      :id   => 1,
      :name => ['matt1', 'matt2']
    }
    assert RSolr::Message.add(data).to_s =~ /<field name="name">matt1<\/field>/
    assert RSolr::Message.add(data).to_s =~ /<field name="name">matt2<\/field>/
  end
  
end