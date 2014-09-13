require "./perfect_partition.rb"
require "./perfect_partition_with_for.rb"
require 'benchmark'

Benchmark.bm do|b| 
  b.report("recurse") do 
    1_00.times { 
      container = Array.new(1) { Array.new(1, nil) }
      perfect_partition(container, 1) 
    }
  end 

  b.report("for") do 
    1_00.times { perfect_partition_with_for } 
  end 
end  
