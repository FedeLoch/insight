"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : 'ManifestInsight',
	#superclass : 'PackageManifest',
	#category : 'Insight-Manifest',
	#package : 'Insight',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestInsight class >> ruleAssignmentInIfTrueRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#IGTest #conditionalMethod: #false)) #'2026-04-15T15:01:04.881253+02:00') )
]

{ #category : 'code-critics' }
ManifestInsight class >> ruleTempsReadBeforeWrittenRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#IGTest #testRecursiveMethodAccumulatesCount #false)) #'2026-04-17T14:22:16.945895+02:00') )
]

{ #category : 'code-critics' }
ManifestInsight class >> ruleYourselfNotUsedRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#IGTest #sequencialMethod #false)) #'2026-04-15T15:01:35.458801+02:00') )
]
