while IFS= read -r url; do
  curl -L -w "$url %{http_code}\n" -o /dev/null -s "$url"
done < urls.txt
