"""Base class for every API schema."""

from pydantic import BaseModel, ConfigDict
from pydantic.alias_generators import to_camel


class ApiSchema(BaseModel):
    """Python fields stay snake_case; the JSON the app sees is camelCase.

    from_attributes lets a schema be built straight from a database row.
    """

    model_config = ConfigDict(
        alias_generator=to_camel,
        populate_by_name=True,
        from_attributes=True,
    )
