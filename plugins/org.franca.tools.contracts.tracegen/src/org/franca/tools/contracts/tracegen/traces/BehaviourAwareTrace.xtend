/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracegen.traces

import java.util.HashMap
import org.eclipse.xtext.EcoreUtil2
import org.franca.core.franca.FArgument
import org.franca.core.franca.FAssignment
import org.franca.core.franca.FBinaryOperation
import org.franca.core.franca.FBlock
import org.franca.core.franca.FBooleanConstant
import org.franca.core.franca.FDeclaration
import org.franca.core.franca.FExpression
import org.franca.core.franca.FIntegerConstant
import org.franca.core.franca.FInterface
import org.franca.core.franca.FState
import org.franca.core.franca.FStringConstant
import org.franca.core.franca.FTransition
import org.franca.core.franca.FTypedElement
import org.franca.tools.contracts.tracegen.strategies.events.EventData
import org.franca.tools.contracts.tracegen.values.ValueGenerator
import org.franca.tools.contracts.tracegen.values.complex.CompoundValue
import org.franca.tools.contracts.tracegen.values.simple.DefaultlyInitializingSimpleValueGenerator
import org.franca.core.franca.FOperator
import org.franca.core.franca.FUnaryOperation
import org.franca.core.franca.FQualifiedElementRef
import org.franca.core.franca.FField
import org.franca.core.franca.FModelElement
import org.eclipse.emf.ecore.EObject
import org.franca.tools.contracts.tracegen.values.complex.ComplexValue

class BehaviourAwareTrace extends Trace {
	
	extension Operators operators = new Operators
	
	ValueGenerator vgen = new ValueGenerator(new DefaultlyInitializingSimpleValueGenerator)
	
	FInterface iface
	
	HashMap<FTypedElement, ElementInstance> elementInstances = newHashMap
	
	new(BehaviourAwareTrace base) {
		super(base)
		this.iface = base.iface
		for (instance : base.elementInstances.entrySet) {
			val instanceCopy = instance.value.copy
			this.elementInstances.put(instance.key, instanceCopy)
		}
	}
	
	new(FState start) {
		super(start)
		EcoreUtil2::getContainerOfType(start, typeof(FInterface))
	}
	
	override use(FTransition transition, EventData triggeringEventData) {
		if (transition.action != null) {
			evaluate(transition.action, triggeringEventData)
		}
		super.use(transition, triggeringEventData)
	}
	
	def dispatch ElementInstance getOrCreate(EObject obj) {
		throw new RuntimeException("It is only possible to create simulated values for typed elements (was " + obj.eClass.name + ")")
	}
	
	def dispatch ElementInstance getOrCreate(FTypedElement e) {
		var currentInstance = elementInstances.get(e)
		if (currentInstance == null) {
			currentInstance = new ElementInstance(e, vgen.createActualValue(e.type))
			elementInstances.put(e, currentInstance)
		}
		return currentInstance
	}
	
// TODO delete:
//	def ElementInstance getOrCreateInitialized(FArgument arg, EventData triggeringEvent) {
//		var currentInstance = elementInstances.get(arg)
//		if (currentInstance == null) {
//			currentInstance = new ElementInstance(arg, triggeringEvent)
//			elementInstances.put(arg, currentInstance)
//		}
//		return currentInstance
//	}
	
	def dispatch Object evaluate(FExpression expr, EventData triggeringEvent) {
		throw new IllegalArgumentException("Unknown type: '" + (expr.class).name+ "'")
		//it is unknown what to do here, right now
	}
	
	def Object evaluateComplexReference(FQualifiedElementRef expr, EventData triggeringEvent) {
		val indirect = expr.qualifier
		if (indirect === null)
			return evaluate(expr, triggeringEvent);
			
		val left = evaluateComplexReference(indirect, triggeringEvent) as CompoundValue
		
		val boolean HANDLE_OTHER_THINGS_THAN_FIELDS_LIKE_FENUMERATORS = true;
		
		return left.getValue(expr.field as FField)
	}
	
	def dispatch Object evaluate(FQualifiedElementRef expr, EventData triggeringEvent) {
		val indirect = expr.qualifier
		if (indirect !== null) {
			return evaluateComplexReference(expr, triggeringEvent)
		}
		
		if (expr.element !== null) {
			if (expr.element instanceof FDeclaration) {
				return getOrCreate(expr.element as FDeclaration).value
			} else if (expr.element instanceof FArgument) {
				val FArgument argument = expr.element as FArgument
				return triggeringEvent.getActualValue(argument)
				//TODO: delete getOrCreateInitialized(argument, triggeringEvent).value
			} 
		} 
		throw new UnsupportedOperationException
	}
	
	def dispatch Object evaluate(FUnaryOperation expr, EventData triggeringEvent) {
		val operand = evaluate(expr.operand, triggeringEvent)
		switch (expr.op) {
			case FOperator::NEGATION: return !(operand as Boolean)
		}
		throw new UnsupportedOperationException
	}
	
	def dispatch Object evaluate(FBinaryOperation expr, EventData triggeringEvent) {
		val left = evaluate(expr.left, triggeringEvent)
		val right = evaluate(expr.right, triggeringEvent)
		
		var Comparable<?> leftToCompare
		var Comparable<?> rightToCompare
		if (left instanceof Float || left instanceof Double || right instanceof Float || right instanceof Double) {
			//TODO: separate Float and Double?
			leftToCompare = (left as Number).doubleValue
			rightToCompare = (right as Number).doubleValue
		} else if (left instanceof Number) {
			leftToCompare = (left as Number).longValue
			rightToCompare = (right as Number).longValue			
		} else {
			leftToCompare = left as Comparable<?>
			rightToCompare = right as Comparable<?>
		}
		
		switch (expr.op) {
			case FOperator::OR: return (left as Boolean || right as Boolean)
			case FOperator::AND: return (left as Boolean && right as Boolean)
			case FOperator::EQUAL: return (leftToCompare.equals(rightToCompare))
			case FOperator::UNEQUAL: return (! left.equals(right))
			case FOperator::SMALLER: return (leftToCompare as Comparable<Object> < rightToCompare)
			case FOperator::GREATER: return ((leftToCompare as Comparable<Object>) > rightToCompare)
			case FOperator::SMALLER_OR_EQUAL: return ((leftToCompare as Comparable<Object>) <= rightToCompare)
			case FOperator::GREATER_OR_EQUAL: return ((leftToCompare as Comparable<Object>) >= rightToCompare)
			case FOperator::ADDITION: return ((leftToCompare as Number) + (rightToCompare as Number))
			case FOperator::SUBTRACTION: return ((leftToCompare as Number) - (rightToCompare as Number))
			case FOperator::MULTIPLICATION: return ((leftToCompare as Number) * (rightToCompare as Number))
			case FOperator::DIVISION: return ((leftToCompare as Number) / (rightToCompare as Number))
		}
		throw new UnsupportedOperationException
	}
	
	def dispatch Object evaluate(FBlock block, EventData triggeringEvent) {
		val iter = block.statements.iterator
		while (iter.hasNext) {
			val result = iter.next.evaluate(triggeringEvent)
			if (! iter.hasNext) {
				return result
			}
		}
		return null;
	}
	
	def dispatch Object evaluate(FBooleanConstant expr, EventData triggeringEvent) {
		expr.isVal
	}
	def dispatch Object evaluate(FIntegerConstant expr, EventData triggeringEvent) {
		expr.^val
	}
	def dispatch Object evaluate(FStringConstant expr, EventData triggeringEvent) {
		expr.^val
	}
	
	def private FModelElement getRoot(FQualifiedElementRef ref) {
		val qualifier = ref.qualifier
		if (qualifier !== null) {
			return getRoot(qualifier)
		}
		val field = ref.field
		if (field !== null) {
			return field
		}
		return ref.element
	}
	
	def dispatch Object evaluate(FAssignment a, EventData triggeringEvent) {
		val declaration = getRoot(a.lhs)
		val currentInstance = getOrCreate(declaration)
		
		val newValue = evaluate(a.rhs, triggeringEvent)
		
		val currentValue = currentInstance.value
		val field = a.lhs.field
		if (currentValue instanceof CompoundValue) {
			if (field instanceof FField) {
				(currentValue as CompoundValue).setValue(a.lhs.field as FField, newValue)
			} else {
				throw new RuntimeException(
					"Try to assign a value to a field in a compound element but " +
					"the reference on the left side did not contain a field.")
			}
		}
		//} else if (currentValue instanceof ArrayValue)
		else if (! (currentValue instanceof ComplexValue)) {
			currentInstance.setValue(newValue)
		} else {
			throw new IllegalArgumentException
		}
		
		return newValue;
	}
	
}