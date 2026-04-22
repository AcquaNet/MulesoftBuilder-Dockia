# What are these rules?
Various [Cursor rules](https://docs.cursor.com/context/rules) that give repeatable context and behavior expectations for
generating different components of UC components.

# How to use
Within your prompt, reference one of these rules with `@`, e.g:
```text
Based on the rule @uc-value-providers.mc create a value provider for field X of the operation defined in file @path/to/operation/file
```

[Original demo here](https://salesforce-internal.slack.com/archives/C06MS5H2H8F/p1746816721878149)
