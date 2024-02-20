defmodule Csv do
  @moduledoc """
  A função parse/1 deve receber o nome de um arquivo CSV no disco.

  Um arquivo CSV é formado por:
  - Uma linha de cabeçalho, que contém o nome das colunas
  - Uma ou mais linhas de dados, onde cada linha contém os valores das colunas

  Após a leitura do arquivo, a função deve retornar uma lista de mapas, onde cada mapa representa uma linha de dados.

  Para isso, a função deve detectar a primeira linha, separar em vírgulas, e depois criar um mapa com
  as chaves sendo os nomes das colunas e os valores sendo os valores das colunas.

  Se o arquivo não existir, a função deve retornar {:error, "File not found"}

  Se o arquivo estiver vazio, a função deve retornar {:error, "File is empty"}

  Se o arquivo não estiver no formato correto, ou seja, se alguma das linhas tiver um número diferente de colunas,
  a função deve retornar {:error, "Invalid CSV"}.

  Você pode assumir que o valor das colunas não contém nenhuma vírgula.
  """

  @spec parse(binary()) :: {:ok, [map()]} | {:error, String.t()}
  def parse(pathFile) do

    case checkFile(pathFile) do
      {:ok, _} ->
        case readAndSeedData(pathFile) do
          {:ok, csvData} ->
            {:ok, csvData}
          {:error, reason} ->
            {:error, reason}
        end
      {:error, reason} ->
        {:error, reason}
    end
  end

  #checks for file existence and if its empty
  defp checkFile(pathFile) do
    case File.stat(pathFile) do
      {:ok, %{size: size}} when size == 0 ->
        {:error, "File is empty"}
      {:ok, _} ->
        {:ok, "Ok"}
      {:error, _} ->
        {:error, "File not found"}
    end
  end

  #reads and parses the data into required structure if data complies with the requirements
  defp readAndSeedData(pathFile) do
    case File.read(pathFile) do
      {:ok, fileData} ->

        rawData =
          fileData
          |> String.split("\n")
          |> Enum.map(&String.trim/1)
          |> Enum.map(&String.split(&1, ","))

        if Enum.all?(rawData, fn rows -> length(rows) == length(Enum.at(rawData, 0)) end) do
          columnNames = List.first(rawData)
          columnValues = List.delete_at(rawData, 0)
          seededData =
            Enum.map(columnValues, fn rowData ->
              Enum.zip(columnNames, rowData) |> Enum.into(%{})
            end)

          {:ok, seededData}
        else
          {:error, "Invalid CSV"}
        end
      {:error, _} ->
        {:error, "Failed to read file"}
    end

  end

end
