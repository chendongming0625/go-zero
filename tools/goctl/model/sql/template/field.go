package template

// Field defines a filed template for types
const Field = `{{.name}} {{.type}} {{.tag}} {{if .hasComment}}// {{.comment}}{{end}}`
const FieldPtr = `{{.name}} *{{.type}} {{.tag}} {{if .hasComment}}// {{.comment}}{{end}}`
