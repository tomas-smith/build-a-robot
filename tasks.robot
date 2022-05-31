*** Settings ***
Documentation       Generates robots from a test site
...                 Saved the HTML receipt as a PDF file
...                 Saves the screenshot of the ordered robot
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive
Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library    RPA.HTTP
Library    RPA.Excel.Files
Library    RPA.Tables
Library    RPA.Desktop
Library    RPA.PDF
Library         RPA.RobotLogListener


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Download .csv file
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
    #    Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
    #    Go to order another robot
    END
    #    Create a ZIP file of the receipts


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Download .csv file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=true
    

Get orders
    
    ${table}=  Read table from CSV   orders.csv
    
 
    [Return]    ${table}

Close the annoying modal
    Click Button    xpath://*[@class="alert-buttons"]/button[2]

fill the form
    [Arguments]    ${newrow}
    Set Local Variable    ${order_no}    ${newrow}[Order number]
    Set Local Variable    ${head}    ${newrow}[Head]
    Set Local Variable    ${body}    ${newrow}[Body]
    Set Local Variable    ${legs}    ${newrow}[Legs]
    Set Local Variable    ${address}    ${newrow}[Address]

    Select From List By Value    id:head    ${head}

    Set Local Variable    ${body_input}    body
    Select Radio Button    ${body_input}    ${body}
    
    

    Set Local Variable    ${leg_input}    xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input
    Input Text    ${leg_input}    ${legs}

    Input Text    id:address    ${address}

Preview the robot
    Click button    id:preview
    Wait Until Element Is Visible    id:preview
    Wait Until Element Is Enabled    id:preview
Submit the order
    
    Mute Run On Failure            id:receipt
    
    click button    id:order
    Wait Until Element Is Visible    id:receipt
    Page Should Contain Element    id:receipt



Store the receipt as a PDF file
    [Arguments]    ${order_number}  
    Wait Until Element Is Visible    id:receipt
    ${receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    Set Local Variable    ${pdf name}    ${OUTPUT_DIR}${/}${order_number}.pdf
    Html To Pdf    cotent=${receipt_html}    output_path=${pdf name}    


Take a screenshot of the robot
    [Arguments]    ${screenshot}
    wait until element is visible    id:robot-preview-image
    Set Local Variable    ${image_preview}   ${OUTPUT_DIR}${/}${screenshot}.png 
    Screenshot    id:robot-preview-image    ${image_preview}