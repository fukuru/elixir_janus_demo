defmodule Acd.Auth.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__

  schema "users" do
    field(:email, :string)
    field(:encrypted_password, :string)
    field(:username, :string)
    field(:password, :string, virtual: true)
    field(:password_confirmation, :string, virtual: true)

    timestamps()
  end

  @type t :: %__MODULE__{
          email: String.t(),
          encrypted_password: String.t(),
          username: String.t(),
          password: String.t(),
          password_confirmation: String.t()
        }

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :username])
    |> validate_required([:email, :username])
    |> validate_length(:username, min: 3, max: 30)
    |> unique_constraint(:email)
    |> unique_constraint(:username)
  end

  @doc false
  def registration_changeset(%User{} = user, attrs) do
    user
    |> changeset(attrs)
    |> validate_confirmation(:password)
    |> cast(attrs, [:password], [])
    |> validate_length(:password, min: 6, max: 128)
    |> encrypt_password()
  end

  defp encrypt_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :encrypted_password, Comeonin.Bcrypt.hashpwsalt(password))

      _ ->
        changeset
    end
  end
end
