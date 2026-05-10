defmodule Uniq.ScopedUUIDTest do
  use ExUnit.Case, async: true

  alias Uniq.ScopedUUID
  alias Uniq.UUID

  defmodule TestSchema do
    use Ecto.Schema

    @primary_key {:id, ScopedUUID, scope: "test", autogenerate: true}
    @foreign_key_type ScopedUUID

    schema "test" do
      belongs_to(:test, TestSchema)
    end
  end

  defmodule UUID4Schema do
    use Ecto.Schema

    @primary_key {:id, ScopedUUID, scope: "version", autogenerate: true, uuid_version: 4}
    @foreign_key_type ScopedUUID

    schema "test" do
      belongs_to(:test, TestSchema)
    end
  end

  @params ScopedUUID.init(
            schema: TestSchema,
            field: :id,
            primary_key: true,
            autogenerate: true,
            scope: "test"
          )
  @belongs_to_params ScopedUUID.init(schema: TestSchema, field: :test, foreign_key: :test_id)
  @loader nil
  @dumper nil

  @test_prefixed_uuid "test_cjKzffwTRMCOG5paB-JJIQ"
  @test_uuid UUID.to_string("7232b37d-fc13-44c0-8e1b-9a5a07e24921", :raw)
  @test_prefixed_uuid_with_leading_zero "test_AYilFryMfFqbaBJlH1WLng"
  @test_uuid_with_leading_zero UUID.to_string("0188a516-bc8c-7c5a-9b68-12651f558b9e", :raw)
  @test_prefixed_uuid_null "test_AAAAAAAAAAAAAAAAAAAAAA"
  @test_uuid_null UUID.to_string("00000000-0000-0000-0000-000000000000", :raw)
  @test_prefixed_uuid_invalid_characters "test_" <> String.duplicate(".", 32)
  @test_uuid_invalid_characters String.duplicate(".", 22)
  @test_prefixed_uuid_invalid_format "test_" <> String.duplicate("x", 31)
  @test_uuid_invalid_format String.duplicate("x", 21)

  test "requires a scope" do
    assert_raise RuntimeError, fn -> ScopedUUID.init(schema: "test", field: :test, version: 7) end
  end

  test "scopes can not include underscores" do
    assert_raise RuntimeError, fn ->
      ScopedUUID.init(schema: "test_foo", field: :test, version: 7)
    end
  end

  test "UUID version is configurable" do
    {:ok, id} = ScopedUUID.generate(TestSchema)
    [_, uuid] = String.split(id, "_", parts: 2)
    assert UUID.info!(uuid).version == 7

    {:ok, id} = ScopedUUID.generate(UUID4Schema, :id)
    [_, uuid] = String.split(id, "_", parts: 2)
    assert UUID.info!(uuid).version == 4
  end

  test "cast/2" do
    assert ScopedUUID.cast(@test_prefixed_uuid, @params) == {:ok, @test_prefixed_uuid}

    assert ScopedUUID.cast(@test_prefixed_uuid_with_leading_zero, @params) ==
             {:ok, @test_prefixed_uuid_with_leading_zero}

    assert ScopedUUID.cast(@test_prefixed_uuid_null, @params) == {:ok, @test_prefixed_uuid_null}
    assert ScopedUUID.cast(nil, @params) == {:ok, nil}
    assert ScopedUUID.cast("otherprefix" <> @test_prefixed_uuid, @params) == :error
    assert ScopedUUID.cast(@test_prefixed_uuid_invalid_characters, @params) == :error
    assert ScopedUUID.cast(@test_prefixed_uuid_invalid_format, @params) == :error

    assert ScopedUUID.cast(@test_prefixed_uuid, @belongs_to_params) ==
             {:ok, @test_prefixed_uuid}
  end

  test "load/3" do
    assert ScopedUUID.load(@test_uuid, @loader, @params) == {:ok, @test_prefixed_uuid}

    assert ScopedUUID.load(@test_uuid_with_leading_zero, @loader, @params) ==
             {:ok, @test_prefixed_uuid_with_leading_zero}

    assert ScopedUUID.load(@test_uuid_null, @loader, @params) == {:ok, @test_prefixed_uuid_null}
    assert ScopedUUID.load(@test_uuid_invalid_characters, @loader, @params) == :error
    assert ScopedUUID.load(@test_uuid_invalid_format, @loader, @params) == :error
    assert ScopedUUID.load(@test_prefixed_uuid, @loader, @params) == :error
    assert ScopedUUID.load(nil, @loader, @params) == {:ok, nil}

    assert ScopedUUID.load(@test_uuid, @loader, @belongs_to_params) ==
             {:ok, @test_prefixed_uuid}
  end

  test "dump/3" do
    assert ScopedUUID.dump(@test_prefixed_uuid, @dumper, @params) == {:ok, @test_uuid}

    assert ScopedUUID.dump(@test_prefixed_uuid_with_leading_zero, @dumper, @params) ==
             {:ok, @test_uuid_with_leading_zero}

    assert ScopedUUID.dump(@test_prefixed_uuid_null, @dumper, @params) == {:ok, @test_uuid_null}
    assert ScopedUUID.dump(@test_uuid, @dumper, @params) == :error
    assert ScopedUUID.dump(nil, @dumper, @params) == {:ok, nil}

    assert ScopedUUID.dump(@test_prefixed_uuid, @dumper, @belongs_to_params) ==
             {:ok, @test_uuid}
  end

  test "autogenerate/1" do
    assert prefixed_uuid = ScopedUUID.autogenerate(@params)
    assert {:ok, uuid} = ScopedUUID.dump(prefixed_uuid, nil, @params)
    assert {:ok, %UUID{format: :raw, version: 7}} = UUID.parse(uuid)
  end
end
