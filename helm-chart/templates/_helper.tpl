{{/* labels of mongo */}}
{{- define "common.mongo" -}}
app: mongo
{{- end }}

{{/* labels of api */}}
{{- define "common.api" -}}
app: student-app-api
{{- end }}

{{/* labels of client */}}
{{- define "common.client" -}}
app: student-app-client
{{- end }}
