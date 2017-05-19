defmodule User do
  use Importex

  import_fields do
    column :email, :email
    column :first_name, :string
    column :last_name, :string
    column :birth, :string
    column :role, :map, values: [{"manager", 0}, {"user", 1}]
    column :gender, :list, values: ["male", "female"]
    column :username, :string
    column :company_id, :integer
    column :contract, :string
    column :salary, :integer
    column :headquarters, :string
  end

end

# Execute =>  mix run benchmark/benchmark.ex

# Elixir 1.4.2
# Erlang 19.3
# Benchmark suite executing with the following configuration:
# warmup: 2.00 s
# time: 5.00 s
# parallel: 1
# inputs: none specified
# Estimated total run time: 14.00 s
#
#
# Benchmarking import_csv...
# Benchmarking import_csv_safe...
#
# Name                      ips        average  deviation         median
# import_csv              14.19       70.49 ms    ±10.47%       69.58 ms
# import_csv_safe         11.89       84.08 ms     ±5.80%       83.09 ms
#
# Comparison:
# import_csv              14.19
# import_csv_safe         11.89 - 1.19x slower
Benchee.run(%{
  "import_csv" => fn -> User.import_csv("#{System.cwd}/benchmark/1000_rows.csv") end,
  "import_csv_safe"  => fn -> User.import_csv_safe("#{System.cwd}/benchmark/1000_rows.csv") end
})
