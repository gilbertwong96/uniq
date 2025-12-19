uuid_string_4a = "db149e97-e4ef-4721-8ee5-93f6a30fdb29"
uuid_string_4b = "b5f534f5-b76e-4667-b1d9-905fe8caef3f"
uuid_string_7a = "019b3755-9921-7aea-a85f-ff750b527fc3"
uuid_string_7b = "019b3755-9bfc-7d2e-8736-d734afa19f99"

uuid_binary_1 = <<1, 155, 55, 87, 4, 95, 116, 181, 191, 179, 47, 102, 228, 223, 130, 13>>
uuid_binary_2 = <<1, 155, 55, 87, 20, 249, 115, 209, 166, 166, 64, 143, 155, 51, 155, 131>>

Benchee.run(
  %{
    "same v4 strings" => fn -> Uniq.UUID.equal?(uuid_string_4a, uuid_string_4a, nil) end,
    "different v4 strings" => fn -> Uniq.UUID.equal?(uuid_string_4a, uuid_string_4b, nil) end,
    "v4 vs v7 strings" => fn -> Uniq.UUID.equal?(uuid_string_4a, uuid_string_7a, nil) end,
    "same v7 binaries" => fn -> Uniq.UUID.equal?(uuid_binary_1, uuid_binary_1, nil) end,
    "different v7 binaries" => fn -> Uniq.UUID.equal?(uuid_binary_1, uuid_binary_1, nil) end,
  }
)
