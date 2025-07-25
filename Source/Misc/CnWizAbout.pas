{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2025 CnPack 开发组                       }
{                   ------------------------------------                       }
{                                                                              }
{            本开发包是开源的自由软件，您可以遵照 CnPack 的发布协议来修        }
{        改和重新发布这一程序。                                                }
{                                                                              }
{            发布这一开发包的目的是希望它有用，但没有任何担保。甚至没有        }
{        适合特定目的而隐含的担保。更详细的情况请参阅 CnPack 发布协议。        }
{                                                                              }
{            您应该已经和开发包一起收到一份 CnPack 发布协议的副本。如果        }
{        还没有，可访问我们的网站：                                            }
{                                                                              }
{            网站地址：https://www.cnpack.org                                  }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnWizAbout;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：专家包帮助、关于单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWin2000Pro + Delphi 5.01
* 兼容测试：PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2025.02.20 V1.2
*               增加每日一帖
*           2004.03.24 V1.1
*               增加每日一帖
*           2003.04.29 V1.0
*               创建单元
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF DEBUG}
{$IFDEF WIN64}
{$IFNDEF SUPPORT_PASCAL_SCRIPT}
  // 64 位的 Debug 状态下，没脚本支持的话就加一个内部查看器供调试使用
  {$DEFINE CN_INTERNAL_EVAL}
{$ENDIF}
{$ENDIF}
{$ENDIF}

uses
  Windows, Messages, SysUtils, Classes, IniFiles, Menus, Forms, Controls,
  CnConsts, CnWizClasses, CnWizManager, CnWizConsts, CnWizUtils, CnCommon,
  CnWizOptions, CnWizIdeUtils;

type

{$IFDEF DEBUG}

  TCnEvaluationExecutor = class(TCnContextMenuExecutor)
  {* 针对一个选中组件的查看菜单项}
  public
    function GetActive: Boolean; override;
    function GetCaption: string; override;
  end;

{$ENDIF}

{ TCnWizAbout }

  TCnWizAbout = class(TCnSubMenuWizard)
  private
    FIdHelp: Integer;
    FIdHistory: Integer;
    FIdTipOfDay: Integer;
    FIdBugReport: Integer;
    FIdUpgrade: Integer;
    FIdConfigIO: Integer;
    FIdUrl: Integer;
    FIdBbs: Integer;
    FIdMail: Integer;
    FIdDonate: Integer;
{$IFDEF CN_INTERNAL_EVAL}
    FIdEval: Integer;
{$ENDIF}
    FIdAbout: Integer;
{$IFNDEF LAZARUS}
{$IFDEF DEBUG}
    FEvaluationExecutor: TCnEvaluationExecutor;
    procedure EvalExecute(Sender: TObject);
{$ENDIF}
{$ENDIF}
  protected
    procedure ConfigIO;
    procedure SubActionExecute(Index: Integer); override;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure AcquireSubActions; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    class function IsInternalWizard: Boolean; override;

    function GetCaption: string; override;
    function GetHint: string; override;
  end;

implementation

uses
  CnWizAboutFrm, CnWizFeedbackFrm, CnWizUpgradeFrm, CnWizTipOfDayFrm
  {$IFDEF DEBUG}, CnDebug {$ENDIF};

{ TCnWizAbout }

procedure TCnWizAbout.ConfigIO;
var
  FileName: string;
begin
  FileName := WizOptions.DllPath + SCnConfigIOName;
  if FileExists(FileName) then
    RunFile(FileName)
  else
    ErrorDlg(SCnConfigIONotExists);
end;

constructor TCnWizAbout.Create;
begin
  inherited;
  // 因为本 Wizard 不会被 Loaded调用，故需要手工 AcquireSubActions;
  AcquireSubActions;

{$IFNDEF LAZARUS}
{$IFDEF DEBUG}
  FEvaluationExecutor := TCnEvaluationExecutor.Create;
  FEvaluationExecutor.OnExecute := EvalExecute;
  RegisterDesignMenuExecutor(FEvaluationExecutor);
{$ENDIF}
{$ENDIF}
end;

destructor TCnWizAbout.Destroy;
begin
{$IFNDEF LAZARUS}
{$IFDEF DEBUG}
  UnRegisterDesignMenuExecutor(FEvaluationExecutor);
  FEvaluationExecutor := nil;
{$ENDIF}
{$ENDIF}
  inherited;
end;

{$IFNDEF LAZARUS}
{$IFDEF DEBUG}

procedure TCnWizAbout.EvalExecute(Sender: TObject);
var
  Sel: TList;
begin
  Sel := TList.Create;
  try
    IdeGetFormSelection(Sel);
    if Sel.Count > 0 then
      CnDebugger.EvaluateObject(Sel[0])
    else
      CnDebugger.EvaluateObject(IdeGetDesignedForm);
  finally
    Sel.Free;
  end;
end;

{$ENDIF}
{$ENDIF}

procedure TCnWizAbout.AcquireSubActions;
begin
  FIdHelp := RegisterASubAction(SCnWizAboutHelp, SCnWizAboutHelpCaption, 0, SCnWizAboutHelpHint);
  FIdHistory := RegisterASubAction(SCnWizAboutHistory, SCnWizAboutHistoryCaption, 0, SCnWizAboutHistoryHint);
  FIdTipOfDay := RegisterASubAction(SCnWizAboutTipOfDay, SCnWizAboutTipOfDaysCaption, 0, SCnWizAboutTipOfDayHint, SCnWizAboutTipOfDay);
  AddSepMenu;
  FIdBugReport := RegisterASubAction(SCnWizAboutBugReport, SCnWizAboutBugReportCaption, 0, SCnWizAboutBugReportHint);
  FIdUpgrade := RegisterASubAction(SCnWizAboutUpgrade, SCnWizAboutUpgradeCaption, 0, SCnWizAboutUpgradeHint);
  FIdConfigIO := RegisterASubAction(SCnWizAboutConfigIO, SCnWizAboutConfigIOCaption, 0, SCnWizAboutConfigIOHint);
  AddSepMenu;
  FIdUrl := RegisterASubAction(SCnWizAboutUrl, SCnWizAboutUrlCaption, 0, SCnWizAboutUrlHint);
  FIdBbs := RegisterASubAction(SCnWizAboutBbs, SCnWizAboutBbsCaption, 0, SCnWizAboutBbsHint);
  FIdMail := RegisterASubAction(SCnWizAboutMail, SCnWizAboutMailCaption, 0, SCnWizAboutMailHint);
  FIdDonate := RegisterASubAction(SCnWizAboutDonate, SCnWizAboutDonateCaption, 0, SCnWizAboutDonateHint);
  AddSepMenu;
{$IFDEF CN_INTERNAL_EVAL}
  FIdEval := RegisterASubAction('CnInternalEvaluate', 'Evaluate Control Under Cursor', TextToShortCut('Alt+1'),
    '', '');
{$ENDIF}
  FIdAbout := RegisterASubAction(SCnWizAboutAbout, SCnWizAboutAboutCaption, 0, SCnWizAboutAboutHint, ClassName);
end;

function TCnWizAbout.GetCaption: string;
begin
  Result := SCnWizAboutCaption;
end;

function TCnWizAbout.GetHint: string;
begin
  Result := SCnWizAboutHint;
end;

class procedure TCnWizAbout.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin

end;

class function TCnWizAbout.IsInternalWizard: Boolean;
begin
  Result := True;
end;

procedure TCnWizAbout.SubActionExecute(Index: Integer);
begin
  if Index = FIdHelp then
    ShowHelp('Index')
  else if Index = FIdHistory then
    ShowHelp('History')
  else if Index = FIdTipOfDay then
    ShowCnWizTipOfDayForm(True)
  else if Index = FIdBugReport then
    ShowFeedbackForm
  else if Index = FIdUpgrade then
    CheckUpgrade(True)
  else if Index = FIdConfigIO then
    ConfigIO
  else if Index = FIdUrl then
    OpenUrl(SCnPackUrl)
  else if Index = FIdBbs then
    OpenUrl(SCnPackBbsUrl)
  else if Index = FIdMail then
    MailTo(SCnPackEmail, SCnWizMailSubject)
  else if Index = FIdDonate then
    ShowHelp('Donation')
{$IFDEF CN_INTERNAL_EVAL}
  else if Index = FIdEval then
    CnDebugger.EvaluateControlUnderPos(Mouse.CursorPos)
{$ENDIF}
  else if Index = FIdAbout then
    ShowCnWizAboutForm;
end;

{$IFDEF DEBUG}

{ TCnEvaluationExecutor }

function TCnEvaluationExecutor.GetActive: Boolean;
begin
  Result := True;
end;

function TCnEvaluationExecutor.GetCaption: string;
begin
  Result := 'Evaluate Selected Component';
end;

{$ENDIF}

end.

