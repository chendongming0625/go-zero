package {{.pkg}}
{{if .withCache}}
import (
	"context"
	"github.com/zeromicro/go-zero/core/stores/cache"
	"github.com/zeromicro/go-zero/core/stores/sqlx"
	"github.com/Masterminds/squirrel"
)
{{else}}
import (
	"context"
	"github.com/zeromicro/go-zero/core/stores/sqlx"
	"github.com/Masterminds/squirrel"	
)

{{end}}
var _ {{.upperStartCamelObject}}Model = (*custom{{.upperStartCamelObject}}Model)(nil)

type (
	// {{.upperStartCamelObject}}Model is an interface to be customized, add more methods here,
	// and implement the added methods in custom{{.upperStartCamelObject}}Model.
	{{.upperStartCamelObject}}Model interface {
		{{.lowerStartCamelObject}}Model
		Trans(ctx context.Context,fn func(context context.Context,session sqlx.Session) error) error
		RowBuilder() squirrel.SelectBuilder
		CountBuilder() squirrel.SelectBuilder
		FindCount(ctx context.Context,countBuilder squirrel.SelectBuilder) (int64,error)
		List(ctx context.Context,rowBuilder squirrel.SelectBuilder,offset ,num int64,orderBy string) ([]*{{.upperStartCamelObject}},error)
		ListForCustom(ctx context.Context,rowBuilder squirrel.SelectBuilder,res interface{}) error 
	}

	custom{{.upperStartCamelObject}}Model struct {
		*default{{.upperStartCamelObject}}Model
	}
)

// New{{.upperStartCamelObject}}Model returns a model for the database table.
func New{{.upperStartCamelObject}}Model(conn sqlx.SqlConn{{if .withCache}}, c cache.CacheConf{{end}}) {{.upperStartCamelObject}}Model {
	return &custom{{.upperStartCamelObject}}Model{
		default{{.upperStartCamelObject}}Model: new{{.upperStartCamelObject}}Model(conn{{if .withCache}}, c{{end}}),
	}
}

func (m *default{{.upperStartCamelObject}}Model) RowBuilder() squirrel.SelectBuilder {
	return squirrel.Select({{.lowerStartCamelObject}}Rows).From(m.table)
}

func (m *default{{.upperStartCamelObject}}Model) CountBuilder() squirrel.SelectBuilder {
	return squirrel.Select("count(*)").From(m.table)
}

func (m *default{{.upperStartCamelObject}}Model) FindCount(ctx context.Context,countBuilder squirrel.SelectBuilder) (int64,error) {

	query, values, err := countBuilder.ToSql()
	if err != nil {
		return 0, err
	}

	var resp int64
	{{if .withCache}}err = m.QueryRowNoCacheCtx(ctx,&resp, query, values...){{else}}
	err = m.conn.QueryRowCtx(ctx,&resp, query, values...)
	{{end}}
	switch err {
	case nil:
		return resp, nil
	default:
		return 0, err
	}
}

func (m *default{{.upperStartCamelObject}}Model) List(ctx context.Context,rowBuilder squirrel.SelectBuilder,offset ,num int64,orderBy string) ([]*{{.upperStartCamelObject}},error) {

	if orderBy == ""{
		rowBuilder = rowBuilder.OrderBy("id DESC")
	}else{
		rowBuilder = rowBuilder.OrderBy(orderBy)
	}
	var (
		query string
		values []interface{}
		err error
	)
	if offset>=0{
		query, values, err= rowBuilder.Offset(uint64(offset)).Limit(uint64(num)).ToSql()
	}else{
		query, values, err= rowBuilder.ToSql()
	}
	
	if err != nil {
		return nil, err
	}

	var resp []*{{.upperStartCamelObject}}
	{{if .withCache}}err = m.QueryRowsNoCacheCtx(ctx,&resp, query, values...){{else}}
	err = m.conn.QueryRowsCtx(ctx,&resp, query, values...)
	{{end}}
	switch err {
	case nil:
		return resp, nil
	default:
		return nil, err
	}
}

func (m *default{{.upperStartCamelObject}}Model) ListForCustom(ctx context.Context,rowBuilder squirrel.SelectBuilder,res interface{}) error {
	query, values, err:= rowBuilder.ToSql()
	if err != nil {
		return err
	}

	{{if .withCache}}return m.QueryRowsNoCacheCtx(ctx,res, query, values...){{else}}
	return m.conn.QueryRowsCtx(ctx,res, query, values...)
	{{end}}
}

func (m *default{{.upperStartCamelObject}}Model) Trans(ctx context.Context,fn func(ctx context.Context,session sqlx.Session) error) error {
	{{if .withCache}}
	return m.TransactCtx(ctx,func(ctx context.Context,session sqlx.Session) error {
		return  fn(ctx,session)
	})
	{{else}}
	return m.conn.TransactCtx(ctx,func(ctx context.Context,session sqlx.Session) error {
		return  fn(ctx,session)
	})
	{{end}}
}