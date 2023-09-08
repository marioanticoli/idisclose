defmodule Idisclose.Policy do
  @moduledoc """
  Authorization policy and helpers for Idisclose resources.

  This module exposes a set of general-purpose authorization helpers as
  well as `Ecto.Repo` wrappers that can be used to enforce authorization
  for common CRUD operations.
  """

  use Janus, repo: Idisclose.Repo

  alias Idisclose.Repo
  alias Idisclose.Accounts.User
  alias Idisclose.Documents.{Section, Template, SectionTemplate, Document, Chapter}

  @impl true
  # for the moment admin and owner role will have the same permissions
  def build_policy(policy, %User{role: role}) when role in [:admin, :owner] do
    policy
    # Sections
    |> allow(Section, :create)
    |> allow(Section, :read)
    |> allow(Section, :update)
    |> allow(Section, :delete)
    # Templates
    |> allow(Template, :create)
    |> allow(Template, :read)
    |> allow(Template, :update)
    |> allow(Template, :delete)
    # SectionTemplates
    |> allow(SectionTemplate, :create)
    |> allow(SectionTemplate, :read)
    |> allow(SectionTemplate, :update)
    |> allow(SectionTemplate, :delete)
    # Documents
    |> allow(Document, :create)
    |> allow(Document, :read)
    |> allow(Document, :update)
    |> allow(Document, :delete)
    |> allow(Document, :archive)
    |> allow(Document, :unarchive)
    # Chapters
    |> allow(Chapter, :create)
    |> allow(Chapter, :read)
    |> allow(Chapter, :update)
    |> allow(Chapter, :delete)
    |> allow(Chapter, :comment)
    |> allow(Chapter, :request_change)
    # Users
    |> allow(User, :create)
    |> allow(User, :read)
    |> allow(User, :update)
    |> allow(User, :delete)
  end

  def build_policy(policy, %User{role: :editor} = user) do
    policy
    # Sections
    |> allow(Section, :read)
    # Templates
    |> allow(Template, :read)
    |> allow(Template, :update)
    # SectionTemplates
    |> allow(SectionTemplate, :create)
    |> allow(SectionTemplate, :read)
    |> allow(SectionTemplate, :update)
    |> allow(SectionTemplate, :delete)
    # Documents
    |> allow(Document, :read)
    |> allow(Document, :update)
    # Chapters
    |> allow(Chapter, :read)
    |> allow(Chapter, :update)
    |> allow(Chapter, :comment)
    |> allow(Chapter, :request_change)
    # Users
    |> allow(User, :read, where: [user: [id: user.id]])
  end

  def build_policy(policy, %User{role: :reviewer} = user) do
    policy
    # Documents
    |> allow(Document, :read)
    # Chapters
    |> allow(Chapter, :read)
    |> allow(Chapter, :comment)
    |> allow(Chapter, :request_change)
    # Users
    |> allow(User, :read, where: [user: [id: user.id]])
  end

  def build_policy(policy, %User{role: :observer} = user) do
    policy
    # Documents
    |> allow(Document, :read)
    # Chapters
    |> allow(Chapter, :read)
    # Users
    |> allow(User, :read, where: [id: user.id])
  end

  def build_policy(policy, _) do
    # deny everything if it didn't match any other role
    policy
  end

  @doc """
  Fetch a single authorized result from a schema or query by key.

  ## Examples

      iex> authorized_fetch_by(Post, [id: 1], authorize: {:read, current_user})
      {:ok, %Post{}}

      iex> authorized_fetch_by(Post, [id: 0], authorize: {:read, current_user})
      {:error, :not_found}

      iex> authorized_fetch_by(Post, [id: 1], authorize: {:not_allowed_action, current_user})
      {:error, :not_authorized}

      iex> authorized_fetch_by(Post, [id: 1], authorize: false)
      {:ok, %Post{}}
  """
  def authorized_fetch_by(queryable, clauses, opts \\ []) do
    {auth, auth_opts, repo_opts} = pop_authorize_opts!(opts, [:load_associations])
    resource = Repo.get_by(queryable, clauses, repo_opts)

    case {resource, auth} do
      {nil, _} -> {:error, :not_found}
      {resource, {action, actor}} -> authorize(resource, action, actor, auth_opts)
      {resource, false} -> {:ok, resource}
    end
  end

  @doc """
  Fetch all authorized entries matching the given query.

  ## Examples

      iex> authorized_fetch_all(Post, authorize: {:read, current_user})
      {:ok, [%Post{}, ...]}

      iex> from(Post, where: [title: "doesn't exist"])
      ...> |> authorized_fetch_all(Post, authorize: {:read, current_user})
      {:ok, []}

      iex> authorized_fetch_all(Post, authorize: {:not_allowed_action, current_user})
      {:error, :not_authorized}

      iex> authorized_fetch_all(Post, authorize: false)
      {:ok, [%Post{}, ...]}
  """
  def authorized_fetch_all(queryable, opts \\ []) do
    {auth, auth_opts, repo_opts} = pop_authorize_opts!(opts, [:preload_authorized])

    with {:auth, {action, actor}} <- {:auth, auth},
         {:any?, true} <- {:any?, any_authorized?(queryable, action, actor)} do
      {:ok, queryable |> scope(action, actor, auth_opts) |> Repo.all(repo_opts)}
    else
      {:auth, false} -> {:ok, Repo.all(queryable, repo_opts)}
      {:any?, false} -> {:error, :not_authorized}
    end
  end

  @doc """
  Delete an entry by its primary key if authorized.

  Accepts a struct or changeset.

  ## Examples

      iex> authorized_delete(post, authorize: {:delete, current_user})
      {:ok, post}

      iex> authorized_delete(unauthorized_post, authorize: {:delete, current_user})
      {:error, %Ecto.Changeset{}}
  """
  def authorized_delete(struct_or_changeset, opts \\ [])

  def authorized_delete(%Ecto.Changeset{} = changeset, opts) do
    {auth, [], repo_opts} = pop_authorize_opts!(opts)

    case auth do
      {action, policy} ->
        changeset
        |> validate_authorized(action, policy,
          message: "is not authorized to delete this resource"
        )
        |> Repo.delete(repo_opts)

      false ->
        Repo.delete(changeset, repo_opts)
    end
  end

  def authorized_delete(struct, opts) do
    authorized_delete(Ecto.Changeset.change(struct), opts)
  end

  @doc """
  Update a changeset by its primary key if authorized.

  ## Examples

      iex> post
      ...> |> Post.changeset(%{title: "updated title"})
      ...> |> authorized_update(authorize: {:update, current_user})
      {:ok, %Post{title: "updated title"}}

      iex> unauthorized_post
      ...> |> Post.changeset(%{title: "updated title"})
      ...> |> authorized_update(authorize: {:update, current_user})
      {:error, %Ecto.Changeset{}}
  """
  def authorized_update(changeset, opts \\ []) do
    {auth, [], repo_opts} = pop_authorize_opts!(opts)

    case auth do
      {action, policy} ->
        changeset
        |> validate_authorized(action, policy)
        |> rollback_unless_authorized(:update, repo_opts, {action, policy})

      false ->
        Repo.update(changeset, repo_opts)
    end
  end

  @doc """
  Inserts a struct or changeset if authorized.

  ## Examples

      iex> authorized_insert(%Post{title: "new post"}, authorize: {:insert, current_user})
      {:ok, %Post{title: "new post"}}

      iex> authorized_insert(%Post{archived: true}, authorize: {:insert, current_user})
      {:error, %Ecto.Changeset{}}
  """
  def authorized_insert(struct_or_changeset, opts \\ [])

  def authorized_insert(%Ecto.Changeset{} = changeset, opts) do
    {auth, [], repo_opts} = pop_authorize_opts!(opts)

    case auth do
      {action, policy} ->
        rollback_unless_authorized(changeset, :insert, repo_opts, {action, policy})

      false ->
        Repo.insert(changeset, repo_opts)
    end
  end

  def authorized_insert(struct, opts) do
    authorized_insert(Ecto.Changeset.change(struct), opts)
  end

  defp rollback_unless_authorized(changeset, op, opts, {action, policy}) do
    Repo.transaction(fn ->
      with {:ok, resource} <- apply(Repo, op, [changeset, opts]),
           {:ok, resource} <- authorize(resource, action, policy) do
        resource
      else
        {:error, %Ecto.Changeset{} = changeset} ->
          Repo.rollback(changeset)

        {:error, :not_authorized} ->
          changeset
          |> Ecto.Changeset.add_error(
            :current_user,
            "is not authorized to make these changes"
          )
          |> Repo.rollback()
      end
    end)
  end

  defp pop_authorize_opts!(opts, extra_keys \\ []) do
    case Keyword.pop(opts, :authorize) do
      {{action, actor}, rest} ->
        {extra, rest} = Keyword.split(rest, extra_keys)
        {{action, build_policy(actor)}, extra, rest}

      {false, rest} ->
        {_, rest} = Keyword.split(rest, extra_keys)
        {false, [], rest}

      {nil, _} ->
        raise ArgumentError, "required option `:authorize` missing from `#{inspect(opts)}`"
    end
  end

  @doc """
  Validate that the resource and changes are authorized.

  ## Options

    * `:message` - the message in case the authorization check fails on
      the resource, defaults to "is not authorized to change this resource"
    * `:error_key` - the key to which the error will be added if
      authorization fails, defaults to `:current_user`

  ## Examples

      iex> %MyResource{}
      ...> |> MyResource.changeset(attrs)
      ...> |> MyPolicy.validate_authorized(:update, current_user)
      %Ecto.Changeset{}
  """
  def validate_authorized(%Ecto.Changeset{} = changeset, action, actor_or_policy, opts \\ []) do
    policy = build_policy(actor_or_policy)

    %{message: message, error_key: key} =
      opts
      |> Keyword.validate!(
        message: "is not authorized to change this resource",
        error_key: :current_user
      )
      |> Map.new()

    case authorize(changeset.data, action, policy) do
      {:ok, _} -> changeset
      {:error, :not_authorized} -> Ecto.Changeset.add_error(changeset, key, message)
    end
  end
end
