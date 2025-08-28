from typing_extensions import Self

from pydantic import BaseModel, ValidationError, model_validator

'''
学习验证器
'''

class Square(BaseModel):
    width: float
    height: float

    @model_validator(mode='before')
    def check_width(self) -> Self:
        if self.width > self.height:
            raise ValueError('width must be positive')
        return self

    @model_validator(mode='after')
    def verify_square(self) -> Self:
        if self.width != self.height:
            raise ValueError('width and height do not match')
        return self

s = Square(width=2, height=1)
print(repr(s))
#> Square(width=1.0, height=1.0)

# try:
#     Square(width=1, height=2)
# except ValidationError as e:
#     print(e)