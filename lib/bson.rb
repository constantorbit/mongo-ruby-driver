# encoding: UTF-8
#
# --
# Copyright (C) 2008-2012 10gen Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ++

module BSON
  if defined? Mongo::DEFAULT_MAX_BSON_SIZE
    DEFAULT_MAX_BSON_SIZE = Mongo::DEFAULT_MAX_BSON_SIZE
  else
    DEFAULT_MAX_BSON_SIZE = 4 * 1024 * 1024
  end

  def self.serialize(obj, check_keys=false, move_id=false)
    BSON_CODER.serialize(obj, check_keys, move_id)
  end

  def self.deserialize(buf=nil)
    BSON_CODER.deserialize(buf)
  end

  # Reads a single BSON document from an IO object.
  # This method is used in the executable b2json, bundled with
  # the bson gem, for reading a file of bson documents.
  #
  # @param [IO] io an io object containing a bson object.
  #
  # @return [ByteBuffer]
  def self.read_bson_document(io)
    bytebuf = BSON::ByteBuffer.new
    sz = io.read(4).unpack("V")[0]
    bytebuf.put_int(sz)
    bytebuf.put_array(io.read(sz-4).unpack("C*"))
    bytebuf.rewind
    return BSON.deserialize(bytebuf)
  end
end

# If JRuby and extensions are enabled, load the java extensions
if RUBY_PLATFORM =~ /java/ && !ENV['BSON_DISABLE_EXT']
  require 'bson/bson_java'
  module BSON
    BSON_CODER = BSON_JAVA
  end
else
  # Skip C-extension if big endian or extensions are disabled
  if "\x01\x00\x00\x00".unpack("i").first != 1 && !ENV['BSON_DISABLE_EXT']
    require 'bson/bson_c'
    module BSON
      BSON_CODER = BSON_C
    end
  else
    require 'bson/bson_ruby'
    module BSON
      BSON_CODER = BSON_RUBY
    end
    unless ENV['TEST_MODE']
      warn "\nNotice: BSON native extension was not loaded. This is required for optimum MongoDB Ruby driver performance."
      warn "  Re-enable the BSON extension with:\n  ENV['BSON_DISABLE_EXT'] = false\n"
    end
  end
end

require 'base64'
require 'bson/bson_ruby'
require 'bson/byte_buffer'
require 'bson/exceptions'
require 'bson/ordered_hash'
require 'bson/types/binary'
require 'bson/types/code'
require 'bson/types/dbref'
require 'bson/types/min_max_keys'
require 'bson/types/object_id'
require 'bson/types/timestamp'
