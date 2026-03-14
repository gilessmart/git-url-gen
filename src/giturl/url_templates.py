from enum import Enum

class TemplateParser:
    class State(Enum):
        PLAIN_TEXT = 1
        FILL_POINT_SEGMENT = 2
        FILL_POINT = 3

    def parse(self, template_str: str) -> Template:
        self.state = self.State.PLAIN_TEXT

        self.text_buf = ""
        self.raw_fp_segment_buf = ""
        self.segments: list[str | FillPointSegment] = []
        self.fp_names = []
        self.fill_point_name_buf = ""

        for char in template_str:
            self.process_char(char)

        if self.state != self.State.PLAIN_TEXT:
            raise ValueError(f"Unclosed fill point segment in template string: {template_str}")
        
        if self.text_buf:
            self.segments.append(self.text_buf)

        return Template(self.segments)
    
    def process_char(self, char: str):
        match self.state:
            case self.State.PLAIN_TEXT:
                if char == "{":
                    # close out text
                    if self.text_buf:
                        self.segments.append(self.text_buf)
                    # open fill point segment
                    self.raw_fp_segment_buf = ""
                    self.fp_names = []
                    self.state = self.State.FILL_POINT_SEGMENT
                else:
                    self.text_buf += char

            case self.State.FILL_POINT_SEGMENT:
                if char == "{":
                    self.raw_fp_segment_buf += char
                    # open fill point
                    self.fill_point_name_buf = ""
                    self.state = self.State.FILL_POINT
                elif char == "}":
                    # close fill point segment
                    self.segments.append(FillPointSegment(self.raw_fp_segment_buf, self.fp_names))
                    # open text
                    self.text_buf = ""
                    self.state = self.State.PLAIN_TEXT
                else:
                    self.raw_fp_segment_buf += char

            case self.State.FILL_POINT:
                if char == "}":
                    self.raw_fp_segment_buf += char
                    # close fill point
                    self.fp_names.append(self.fill_point_name_buf)
                    # back to fill point segment
                    self.state = self.State.FILL_POINT_SEGMENT
                else:
                    self.raw_fp_segment_buf += char
                    self.fill_point_name_buf += char


class Template:
    def __init__(self, segments: list[str | FillPointSegment]):
        self.segments = segments

    def apply(self, template_args: dict) -> str:
        result = ""
        for seg in self.segments:
            if isinstance(seg, str):
                result += seg
            elif isinstance(seg, FillPointSegment):
                result += seg.apply(template_args)
        return result


class FillPointSegment:
    def __init__(self, raw: str, fill_points_names: list[str]):
        self.raw = raw
        self.fill_point_names = fill_points_names

    def apply(self, template_args: dict) -> str:
        # if any of the fill points are missing or empty, return empty string
        for fpn in self.fill_point_names:
            if fpn not in template_args or not template_args[fpn]:
                return ""
        # otherwise replace all fill points with their corresponding values
        result = self.raw
        for fpn in self.fill_point_names:
            fill_point = f"{{{fpn}}}"
            result = result.replace(fill_point, template_args[fpn])
        return result
