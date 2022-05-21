unit MarkdownPrepareHtml;

interface

uses
  System.Classes, System.SysUtils, MarkdownProcessor;

type
  TPrepareMarkdown = class
  private
    FTemplate: TStrings;
    FSource: TStrings;
    FHtml: TStrings;
    FTitle: String;
    procedure InitTemplate;
  protected
  public
    constructor Create;
    destructor Destroy; override;

    property Template: TStrings read FTemplate;
    property Source: TStrings read FSource;
    property Html: TStrings read FHtml;
    property Title: String read FTitle write FTitle;

    procedure Process;
  end;

procedure PrepareMarkdownFile(const ATemplateFileName, ASourceFileName, AResultFileName: String);

implementation

procedure PrepareMarkdownFile(const ATemplateFileName, ASourceFileName, AResultFileName: String);
var
  Processor: TMarkdownProcessor;
  StringStream: TStringStream;
  TemplateStrings: TStringList;
begin
  TemplateStrings := TStringList.Create;
  try
    StringStream := TStringStream.Create;
    try
      StringStream.LoadFromFile(ASourceFileName);
      TemplateStrings.LoadFromFile(ExtractFilePath(ATemplateFileName) + 'markdown-template.html');
      Processor := TMarkdownProcessor.CreateDialect(TMarkdownProcessorDialect.mdCommonMark);
      try
        // Processor.AllowUnsafe := False;
        TemplateStrings.Text :=
          TemplateStrings.Text
            .Replace('<!-- title -->', ChangeFileExt(ExtractFileName(ASourceFileName), ''), [rfIgnoreCase])
            .Replace('<!-- content -->', Processor.process(StringStream.DataString), [rfIgnoreCase]);
        TemplateStrings.SaveToFile(AResultFileName);
      finally
        Processor.Free;
      end;
    finally
      StringStream.Free;
    end;
  finally
    TemplateStrings.Free;
  end;
end;

{ TPrepareMarkdown }

constructor TPrepareMarkdown.Create;
begin
  inherited;
  FTemplate := TStringList.Create;
  InitTemplate;

  FSource := TStringList.Create;
  FHtml := TStringList.Create;
  FTitle := '';
end;

destructor TPrepareMarkdown.Destroy;
begin
  FHtml.Free;
  FSource.Free;
  FTemplate.Free;
  inherited;
end;

procedure TPrepareMarkdown.InitTemplate;
begin
  Template.Clear;
  Template.Add('<!DOCTYPE html>');
  Template.Add('<html lang="ru">');
  Template.Add('    <head>');
  Template.Add('        <title><!-- title --></title>');
  Template.Add('        <meta charset="utf-8"/>');
  Template.Add('        <link rel="stylesheet" href="markdown.css"/>');
  Template.Add('    </head>');
  Template.Add('    <body>');
  Template.Add('        <div id="md">');
  Template.Add('            <!-- content -->');
  Template.Add('        </div>');
  Template.Add('    </body>');
  Template.Add('</html>');
end;

procedure TPrepareMarkdown.Process;
var
  Processor: TMarkdownProcessor;
begin
  Processor := TMarkdownProcessor.CreateDialect(TMarkdownProcessorDialect.mdCommonMark);
  try
    // Processor.AllowUnsafe := False;
    Html.Text :=
      Template.Text
        .Replace('<!-- title -->', Title, [rfIgnoreCase])
        .Replace('<!-- content -->', Processor.process(Source.Text), [rfIgnoreCase]);
  finally
    Processor.Free;
  end;
end;

end.